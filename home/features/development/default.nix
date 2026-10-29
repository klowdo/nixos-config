{pkgs, ...}: {
  imports = [
    ./languages
    ./tools
    ./mcp-gateway.nix
    # ./cura.nix  # 3D printing, may have Linux deps
    # ./orca.nix  # 3D printing
    # ./super-slicer.nix  # 3D printing
    # ./bambu-studio.nix  # 3D printing
    # ./nix-flatpak.nix  # Linux-only: Flatpak
    # ./claude-desktop.nix  # May conflict with copilot-cli
    # ./opencode.nix  # May be Linux-specific
    ./freecad.nix
    # ./mongo-compass.nix  # GUI tool with Linux-specific deps
    # ./wakapi.nix  # May use systemd
    ./copilot-cli.nix
    # ./codex.nix  # Unknown compatibility
    # ./kubernetes.nix  # May have Linux-specific deps
  ];

  home.packages = with pkgs; [
    unstable.devenv
  ];
}
