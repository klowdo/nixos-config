{pkgs}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    ruff
    pyright
  ];
}
