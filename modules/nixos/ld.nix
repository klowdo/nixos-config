{
  flake.modules.nixos.ld = {pkgs, ...}: {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      mpifileutils
      icu
      icu.dev
    ];

    environment.systemPackages = with pkgs; [
      icu
    ];
  };
}
