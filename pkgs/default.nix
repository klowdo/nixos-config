# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  #
  #   #################### Packages with external source ####################
  # https://github.com/EmergentMind/nix-config/blob/14adb9899cb101d0599dc3d7aa88a70ba4cf0388/pkgs/default.nix
  # cd-gitroot = pkgs.callPackage ./cd-gitroot { };
  # zhooks = pkgs.callPackage ./zhooks { };
  # zsh-term-title = pkgs.callPackage ./zsh-term-title { };
}
