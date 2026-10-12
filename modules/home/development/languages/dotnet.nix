{...}: {
  flake.modules.homeManager.dotnet = {
    config,
    pkgs,
    ...
  }: {
    home = {
      packages = [
        pkgs.dotnet-combined
        pkgs.grpc
        pkgs.protobuf
        pkgs.azure-artifacts-credprovider
        (pkgs.azure-cli.withExtensions [pkgs.azure-cli-extensions.azure-devops])
        pkgs.nssTools
        pkgs.openssl
      ];
      sessionVariables = {
        DOTNET_ROOT = "${pkgs.dotnet-combined}/share/dotnet";
        PROTOBUF_PROTOC = "${pkgs.protobuf}/bin/protoc";
        GRPC_PROTOC_PLUGIN = "${pkgs.grpc}/bin/grpc_csharp_plugin";
        # SSL_CERT_DIR replaces the default CA search path; without the system
        # bundle alongside it, every tool honouring it loses all public CAs.
        SSL_CERT_DIR = "${config.home.homeDirectory}/.aspnet/dev-certs/trust";
        SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      };
      # ponytail: dotnet dev-certs globs `*.default` for firefox profiles; home-manager names it `default`
      file.".mozilla/firefox/hm.default".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.mozilla/firefox/default";

      sessionPath = [
        "${config.home.homeDirectory}/.dotnet/tools"
      ];
    };
  };
}
