{
  inputs,
  outputs,
  ...
}: let
  username = "FSVENS28";
in {
  imports = [inputs.home-manager.darwinModules.home-manager];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    overlays = builtins.attrValues outputs.overlays;
    config.allowUnfree = true;
  };

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
    casks = [];
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    backupFileExtension = "hm-backup";
    users.${username} = import ../../home/klowdo/D9PDHCXWH6.nix;
  };

  system.stateVersion = 6;
}
