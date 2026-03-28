{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.auto-shell;

  shellType = types.submodule {
    options.paths = mkOption {
      type = types.listOf types.str;
      description = "Glob patterns for directories that should activate this shell.";
    };
  };

  tomlShells =
    concatStringsSep "\n"
    (mapAttrsToList (name: shell: ''
        [[shells]]
        name = "${name}"
        paths = [${concatMapStringsSep ", " (p: ''"${p}"'') shell.paths}]
      '')
      cfg.shells);

  tomlIncludes =
    if cfg.includes == []
    then ""
    else "includes = [${concatMapStringsSep ", " (p: ''"${p}"'') cfg.includes}]";

  configToml = pkgs.writeText "auto-shell-config.toml" ''
    ${tomlIncludes}

    ${tomlShells}
  '';

  shellsTxt =
    pkgs.writeText "auto-shell-shells.txt"
    (concatMapStringsSep "\n" (s: s) cfg.availableShells + "\n");

  flakePath = cfg.flakePath;
in {
  options.features.cli.auto-shell = {
    enable = mkEnableOption "auto-shell: directory-based nix dev environment loader";

    flakePath = mkOption {
      type = types.str;
      default = "~/.dotfiles";
      description = "Path to the flake containing devShell definitions.";
    };

    shells = mkOption {
      type = types.attrsOf shellType;
      default = {};
      description = "Map of shell names to directory glob patterns.";
    };

    availableShells = mkOption {
      type = types.listOf types.str;
      default = builtins.attrNames cfg.shells;
      description = "List of devShell names available for interactive discovery. Defaults to shells defined in this config.";
    };

    includes = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional TOML config files to include (same [[shells]] format).";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."auto-shell/config.toml".source = configToml;
    xdg.configFile."auto-shell/shells.txt".source = shellsTxt;

    home.packages = [pkgs.dasel pkgs.fzf];

    programs.zsh.initContent = let
      dasel = "${pkgs.dasel}/bin/dasel";
      fzf = "${pkgs.fzf}/bin/fzf";
    in ''
      typeset -gA _AUTOSHELL_MAP
      typeset -g _AUTOSHELL_ACTIVE=""
      typeset -g _AUTOSHELL_ORIG_PATH=""
      typeset -gA _AUTOSHELL_PATH_CACHE
      typeset -g _AUTOSHELL_PROMPT_TAG=""

      _autoshell_load_config() {
        _AUTOSHELL_MAP=()
        local config_file="${config.xdg.configHome}/auto-shell/config.toml"
        [[ -f "$config_file" ]] || return

        _autoshell_parse_file "$config_file"

        local includes
        includes=$(${dasel} -f "$config_file" -r toml -w plain 'includes.all()' 2>/dev/null) || true
        if [[ -n "$includes" ]]; then
          while IFS= read -r inc; do
            inc="''${inc/#\~/$HOME}"
            [[ -f "$inc" ]] && _autoshell_parse_file "$inc"
          done <<< "$includes"
        fi

        local local_file="${config.xdg.configHome}/auto-shell/local.toml"
        [[ -f "$local_file" ]] && _autoshell_parse_file "$local_file"
      }

      _autoshell_parse_file() {
        local file="$1"
        local count
        count=$(${dasel} -f "$file" -r toml 'shells.len()' 2>/dev/null) || return
        for ((i=0; i<count; i++)); do
          local name
          name=$(${dasel} -f "$file" -r toml -w plain "shells.[$i].name" 2>/dev/null) || continue
          local paths
          paths=$(${dasel} -f "$file" -r toml -w plain "shells.[$i].paths.all()" 2>/dev/null) || continue
          while IFS= read -r p; do
            p="''${p/#\~/$HOME}"
            _AUTOSHELL_MAP[$p]="$name"
          done <<< "$paths"
        done
      }

      _autoshell_match() {
        local dir="$1"
        for pattern in "''${(@k)_AUTOSHELL_MAP}"; do
          if [[ "$dir" = ''${~pattern} || "$dir" = ''${~pattern}/* ]]; then
            echo "''${_AUTOSHELL_MAP[$pattern]}"
            return 0
          fi
        done
        return 1
      }

      _autoshell_git_root() {
        git -C "$1" rev-parse --show-toplevel 2>/dev/null
      }

      _autoshell_append_local() {
        local name="$1" path="$2"
        local local_file="${config.xdg.configHome}/auto-shell/local.toml"
        printf '\n[[shells]]\nname = "%s"\npaths = ["%s"]\n' "$name" "$path" >> "$local_file"
        _autoshell_load_config > /dev/null
      }

      _autoshell_discover() {
        local git_root
        git_root=$(_autoshell_git_root "$PWD") || return
        local short_path="''${git_root/#$HOME/~}"

        _autoshell_match "$git_root" >/dev/null 2>&1 && return

        local shells_file="${config.xdg.configHome}/auto-shell/shells.txt"
        [[ -f "$shells_file" ]] || return

        local selection
        selection=$(cat "$shells_file" <(echo "[skip]") | ${fzf} --prompt="auto-shell ($short_path): " --height=~10 --reverse)
        [[ -z "$selection" ]] && return

        if [[ "$selection" == "[skip]" ]]; then
          _autoshell_append_local "none" "$short_path"
        else
          _autoshell_append_local "$selection" "$short_path"
          _autoshell_activate "$selection"
        fi
      }

      _autoshell_activate() {
        local shell_name="$1"
        [[ "$shell_name" == "none" ]] && return
        [[ "$_AUTOSHELL_ACTIVE" = "$shell_name" ]] && return

        if [[ -n "$_AUTOSHELL_ACTIVE" ]]; then
          _autoshell_deactivate
        fi

        _AUTOSHELL_ORIG_PATH="$PATH"

        if [[ -n "''${_AUTOSHELL_PATH_CACHE[$shell_name]}" ]]; then
          PATH="''${_AUTOSHELL_PATH_CACHE[$shell_name]}:$PATH"
        else
          local flake="${flakePath}"
          flake="''${flake/#\~/$HOME}"
          local nix_path
          nix_path=$(nix develop "$flake#$shell_name" -c sh -c 'echo $PATH' 2>/dev/null) || {
            echo "auto-shell: failed to load shell '$shell_name'" >&2
            return 1
          }
          local new_entries=""
          local IFS=':'
          for entry in $nix_path; do
            if [[ ":$PATH:" != *":$entry:"* ]]; then
              new_entries="''${new_entries:+$new_entries:}$entry"
            fi
          done
          _AUTOSHELL_PATH_CACHE[$shell_name]="$new_entries"
          PATH="$new_entries:$PATH"
        fi

        _AUTOSHELL_ACTIVE="$shell_name"
        echo "auto-shell: activated '$shell_name'"
      }

      _autoshell_deactivate() {
        [[ -z "$_AUTOSHELL_ACTIVE" ]] && return
        PATH="$_AUTOSHELL_ORIG_PATH"
        _AUTOSHELL_ORIG_PATH=""
        echo "auto-shell: deactivated '$_AUTOSHELL_ACTIVE'"
        _AUTOSHELL_ACTIVE=""
      }

      _autoshell_chpwd() {
        local matched
        matched=$(_autoshell_match "$PWD")
        if [[ $? -eq 0 && -n "$matched" ]]; then
          _autoshell_activate "$matched"
        elif [[ -n "$_AUTOSHELL_ACTIVE" ]]; then
          _autoshell_deactivate
        else
          _autoshell_discover
        fi
      }

      _autoshell_prompt_info() {
        [[ -n "$_AUTOSHELL_ACTIVE" ]] && echo -n "%{$fg[yellow]%}($_AUTOSHELL_ACTIVE)%{$reset_color%} "
      }

      _autoshell_load_config > /dev/null
      autoload -Uz add-zsh-hook
      add-zsh-hook chpwd _autoshell_chpwd
      PROMPT=''${PROMPT/'$(git_prompt_info)'/'$(_autoshell_prompt_info)$(git_prompt_info)'}
    '';
  };
}
