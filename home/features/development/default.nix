{pkgs, ...}: {
  imports = [
    ./languages
    ./tools
    ./cura.nix
  ];

  home.packages = with pkgs; [
    devenv
  ];
}
