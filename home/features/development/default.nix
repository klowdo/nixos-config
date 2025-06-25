{pkgs, ...}: {
  imports = [
    ./languages
    ./tools
    ./cura.nix
    ./orca.nix
    ./super-slicer.nix
  ];

  home.packages = with pkgs; [
    devenv
  ];
}
