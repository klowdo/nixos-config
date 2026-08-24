{pkgs}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    dotnet-combined
    grpc
    protobuf
    azure-artifacts-credprovider
  ];
  DOTNET_ROOT = "${pkgs.dotnet-combined}/share/dotnet";
  PROTOBUF_PROTOC = "${pkgs.protobuf}/bin/protoc";
  GRPC_PROTOC_PLUGIN = "${pkgs.grpc}/bin/grpc_csharp_plugin";
}
