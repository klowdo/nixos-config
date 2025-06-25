{pkgs, ...}: {
  imports = [
    ./languages
    ./tools
    ./cura.nix
    ./orca.nix
  ];

  home.packages = with pkgs; [
    devenv
  ];
}
