{pkgs}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    go
    gopls
    gotools
    delve
  ];
}
