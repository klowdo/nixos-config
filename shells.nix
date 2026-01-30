{
  pkgs,
  pre-commit-check,
  ...
}: {
  default = pkgs.mkShell {
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
