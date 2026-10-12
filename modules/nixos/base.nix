{
  inputs,
  config,
  ...
}: let
  inherit (config) flake;
in {
  flake.modules.nixos.base = {
    pkgs,
    lib,
    ...
  }: {
    imports =
      [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (with flake.modules.nixos; [
        nh
        firmware-update
        firewall
        tailscale
        yubikey
        sops
        locale
        nix
        option-host-config
        option-nvidia-greenboost
      ]);

    home-manager = {
      useUserPackages = true;
      extraSpecialArgs = {inherit inputs;};
      backupFileExtension = "bak";
    };

    nixpkgs = {
      overlays = builtins.attrValues flake.overlays;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = [
          "root"
          "klowdo"
        ];
      };
      optimise.automatic = true;
      registry =
        (lib.mapAttrs (_: input: {flake = input;}))
        ((lib.filterAttrs (_: lib.isType "flake")) inputs);
      nixPath = ["/etc/nix/path"];
    };

    users.defaultUserShell = pkgs.zsh;

    hostConfig.mainUser = "klowdo";

    system.stateVersion = "26.05";
  };
}
