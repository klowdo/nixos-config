{
  pkgs,
  inputs,
}: {
  zig = import ./zig.nix {inherit pkgs inputs;};
  go = import ./go.nix {inherit pkgs;};
  python = import ./python.nix {inherit pkgs;};
  dotnet = import ./dotnet.nix {inherit pkgs;};
}
