# { pkgs, lib, config, inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.languages.dotnet;
  # dotnet-combined = with pkgs.unstable.dotnetCorePackages;
  #   (combinePackages [
  #     sdk_8_0_3xx
  #     sdk_9_0
  #   ])
  #   .overrideAttrs (finalAttrs: previousAttrs: {
  #     # This is needed to install workload in $HOME
  #     # https://discourse.nixos.org/t/dotnet-maui-workload/20370/2
  #     postBuild =
  #       (previousAttrs.postBuild or '''')
  #       + ''
  #          for i in $out/sdk/*
  #          do
  #            i=$(basename $i)
  #            length=$(printf "%s" "$i" | wc -c)
  #            substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
  #            i="$substring""00"
  #            mkdir -p $out/metadata/workloads/''${i/-*}
  #            touch $out/metadata/workloads/''${i/-*}/userlocal
  #         done
  #       '';
  #   });
in {
  options.features.development.languages.dotnet.enable = mkEnableOption "enable dotnet lang sdk";
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.dotnet-combined
      pkgs.grpc
      pkgs.protobuf
    ];
    home.sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-combined}/share/dotnet";
      PROTOBUF_PROTOC = "${pkgs.protobuf}/bin/protoc";
      GRPC_PROTOC_PLUGIN = "${pkgs.grpc}/bin/grpc_csharp_plugin";
    };

    home.sessionPath = [
      "/home/klowdo/.dotnet/tools"
    ];
  };
}
