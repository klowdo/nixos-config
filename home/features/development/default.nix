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
    ./claude-desktop.nix
    ./opencode.nix
    ./freecad.nix
    ./mongo-compass.nix
    ./wakapi.nix
    ./copilot-cli.nix
    ./kubernetes.nix
  ];

  home.packages = with pkgs; [
    unstable.devenv
  ];
}
