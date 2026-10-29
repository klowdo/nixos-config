{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  username = "FSVENS28";
in {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./kanata.nix
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    overlays =
      builtins.attrValues outputs.overlays
      ++ [
        # https://lix.systems/add-to-config/
        (final: prev: {
          inherit
            (prev.lixPackageSets.latest)
            nixpkgs-review
            nix-eval-jobs
            nix-fast-build
            colmena
            ;
        })
      ];
    config.allowUnfree = true;
  };

  # Installed via the Lix installer; stable (2.94) would downgrade it
  nix.package = pkgs.lixPackageSets.latest.lix;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = ["@admin" username];
  };

  networking.hostName = "D9PDHCXWH6";

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  programs.zsh.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation.cleanup = "none";
    brews = [
      "starship"
      "tailscale"
      "yabai"
      "skhd"
    ];
    casks = [
      "amethyst"
      "claude-code"
      "copilot-cli"
      "firefox"
      "ghostty"
      "raycast"
    ];
  };

  launchd.user.agents = {
    yabai = {
      enable = true;
      config = {
        Label = "com.koekeishiya.yabai";
        Program = "${pkgs.yabai}/bin/yabai";
        ProgramArguments = ["${pkgs.yabai}/bin/yabai" "-c" "/Users/${username}/.config/yabai/yabairc"];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/yabai.out.log";
        StandardErrorPath = "/tmp/yabai.err.log";
      };
    };
    skhd = {
      enable = true;
      config = {
        Label = "com.koekeishiya.skhd";
        Program = "${pkgs.skhd}/bin/skhd";
        ProgramArguments = ["${pkgs.skhd}/bin/skhd" "-c" "/Users/${username}/.config/skhd/skhdrc"];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/skhd.out.log";
        StandardErrorPath = "/tmp/skhd.err.log";
      };
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    backupFileExtension = "hm-backup";
    users.${username} = import ../../home/klowdo/D9PDHCXWH6.nix;
  };

  system.stateVersion = 6;
}
