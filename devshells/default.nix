{pkgs}: {
  zig = import ./zig.nix {inherit pkgs;};
  go = import ./go.nix {inherit pkgs;};
  python = import ./python.nix {inherit pkgs;};
}
