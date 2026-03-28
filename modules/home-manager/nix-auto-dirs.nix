# Centralized directory-to-flake mappings for direnv
# Automatically generates .envrc files and allows them in direnv,
# without placing any tracked files in the target repositories.
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.nix-auto-dirs;

  dirEntry = types.submodule {
    options = {
      flake = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Flake reference to use (e.g. path, github:user/repo). Uses `use flake <ref>`.";
      };

      extraEnvrc = mkOption {
        type = types.lines;
        default = "";
        description = "Extra lines to append to the generated .envrc.";
      };
    };
  };
in {
  options.programs.nix-auto-dirs = {
    enable = mkEnableOption "centralized direnv auto-loading for directories";

    directories = mkOption {
      type = types.attrsOf dirEntry;
      default = {};
      description = ''
        Map of directory paths (relative to $HOME) to their direnv/flake configuration.
        Generates .envrc files at those paths and auto-allows them in direnv.
      '';
      example = literalExpression ''
        {
          "dev/myproject" = { flake = "github:user/myflake"; };
          "dev/work/api" = { flake = "/home/user/flakes/work"; extraEnvrc = "export API_ENV=dev"; };
        }
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.directories != {}) (let
    homeDir = config.home.homeDirectory;
    dirNames = attrNames cfg.directories;
  in {
    # Generate .envrc files at each configured directory (paths relative to $HOME)
    home.file =
      mapAttrs' (dir: entry:
        nameValuePair "${dir}/.envrc" {
          text = let
            flakeLine =
              if entry.flake != null
              then "use flake ${entry.flake}"
              else "";
          in
            concatStringsSep "\n" (filter (s: s != "") [flakeLine entry.extraEnvrc])
            + "\n";
          force = true;
        })
      cfg.directories;

    # Auto-allow the generated .envrc files in direnv (needs absolute paths)
    programs.direnv.config.whitelist.exact =
      map (dir: "${homeDir}/${dir}/.envrc") dirNames;

    # Add .envrc to each target directory's .git/info/exclude via an activation script
    # This avoids polluting the global gitignore (which would hide tracked .envrc files
    # in other repos) and keeps the ignore scoped to only the managed directories.
    home.activation.nix-auto-dirs-git-exclude = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for dir in ${concatStringsSep " " (map (d: ''"${homeDir}/${d}"'') dirNames)}; do
        exclude="$dir/.git/info/exclude"
        if [ -d "$dir/.git/info" ]; then
          for entry in .envrc .direnv; do
            if ! grep -qxF "$entry" "$exclude" 2>/dev/null; then
              echo "$entry" >> "$exclude"
            fi
          done
        fi
      done
    '';
  });
}
