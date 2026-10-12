{inputs, ...}: {
  flake.lib.custom = import ../../lib {inherit (inputs.nixpkgs) lib;};
}
