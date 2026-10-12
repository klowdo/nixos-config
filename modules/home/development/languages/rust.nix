{...}: {
  flake.modules.homeManager.rust = {
    config,
    pkgs,
    ...
  }: {
    home = {
      packages = with pkgs; [
        rustup
        gcc
        pkg-config
        openssl
      ];
    };

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
