{
  pkgs,
  pre-commit-check,
  ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    nativeBuildInputs = [
      pkgs.libiconv
      pkgs.nix
      pkgs.home-manager
      pkgs.git
      pkgs.just
      pkgs.age
      pkgs.age-plugin-yubikey
      pkgs.ssh-to-age
      pkgs.sops
    ];
    inherit (pre-commit-check) shellHook;
  };
}
