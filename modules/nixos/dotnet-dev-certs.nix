# dotnet dev-certs https --format PEM -ep server.crt
{
  flake.modules.nixos.dotnet-dev-certs = {
    sops.secrets.dotnet-dev-cert = {};
  };
}
