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

      # SOPS + age encryption with hardware security plugins
      pkgs.sops
      pkgs.age
      pkgs.ssh-to-age
      pkgs.age-plugin-yubikey # YubiKey support for age
      pkgs.age-plugin-tpm # TPM 2.0 support for age
    ];
    inherit (pre-commit-check) shellHook;
  };
}
