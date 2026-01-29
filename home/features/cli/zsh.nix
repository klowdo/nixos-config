{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.zsh;
in {
  options.features.cli.zsh.enable = mkEnableOption "enable extended zsh configuration";

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        ls = "eza";
        grep = "rg";
        ps = "procs";
        lg = "lazygit";
        ndev = "nix run ~/dev/github/kixvim";
        e = "nvim";
        edit = "nvim";
        # dive = "docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive";
        dotent = "dotnet"; # because fuck you

        # Nvidia specialisation shortcuts
        reboot-nvidia = "sudo bootctl set-oneshot $(bootctl list | grep specialisation-nvidia | head -1 | awk '{print $2}') && reboot";
        switch-nvidia = "sudo /nix/var/nix/profiles/system/specialisation/nvidia/bin/switch-to-configuration test";
        switch-default = "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration test";
      };
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      initContent = lib.mkBefore ''
        # Add just command runner completions to fpath (before compinit)
        fpath=(${pkgs.just}/share/zsh/site-functions $fpath)
      '';

      loginExtra = ''
          export NIX_LOG=info
          export TERMINAL=kitty

        if [[ $(tty) == "/dev/tty1" ]]; then
            exec Hyprland &> /dev/null
        fi
      '';

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = ["git" "sudo" "dotnet"];
      };
    };
  };
}
