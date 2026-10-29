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
      "golang"
    ];
    casks = [
      "amethyst"
      "claude-code"
      "copilot-cli"
      "firefox"
      "ghostty"
      "raycast"
      "slack"
    ];
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    backupFileExtension = "hm-backup";
    users.${username} = import ../../home/klowdo/D9PDHCXWH6.nix;
  };

  system.stateVersion = 6;
}
