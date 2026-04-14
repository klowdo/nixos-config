{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.languages.rust;
in {
  options.features.development.languages.rust.enable = mkEnableOption "enable rust toolchain";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rustup
      gcc
      pkg-config
      openssl
    ];

    home.sessionVariables = {
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
    };

    home.sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin"
    ];
  };
}
