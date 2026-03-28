{pkgs}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    zig
    zls
  ];
}
