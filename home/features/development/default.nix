{pkgs, ...}: {
  imports = [
    ./languages
    ./tools
    ./cura.nix
    ./orca.nix
    ./super-slicer.nix
    ./nix-flatpak.nix
  ];

  home.packages = with pkgs; [
    devenv
  ];
  
}
