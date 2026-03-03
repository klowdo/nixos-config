{pkgs, ...}: {
  imports = [
    ./languages
    ./tools
    ./mcp-gateway.nix
    ./cura.nix
    ./orca.nix
    ./super-slicer.nix
    ./bambu-studio.nix
    ./nix-flatpak.nix
    ./freecad.nix
    ./mongo-compass.nix
    ./wakapi.nix
  ];

  home.packages = with pkgs; [
    devenv
  ];
}
