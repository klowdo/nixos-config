{ pkgs, lib, config, inputs, ... }:

let
  pkgs-stable = import inputs.nixpkgs-stable { system = pkgs.stdenv.system; };
  dotnet-combined = (with pkgs.dotnetCorePackages; combinePackages [
    sdk_8_0
  ]).overrideAttrs (finalAttrs: previousAttrs: {
    # This is needed to install workload in $HOME
    # https://discourse.nixos.org/t/dotnet-maui-workload/20370/2
    postBuild = (previousAttrs.postBuild or '''') + ''
       for i in $out/sdk/*
       do
         i=$(basename $i)
         length=$(printf "%s" "$i" | wc -c)
         substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
         i="$substring""00"
         mkdir -p $out/metadata/workloads/''${i/-*}
         touch $out/metadata/workloads/''${i/-*}/userlocal
      done

      mkdir -p $out/home
      export HOME=$out/home
      export DOTNET_ROOT=$out 
      $out/dotnet workload install aspire
    '';
  });
in
rec
{
  env.GREET = "avalonia";
  env.DOTNET_ROOT = "${dotnet-combined}";
  languages.dotnet.enable = true;
  languages.dotnet.package = dotnet-combined;
  packages = [
    pkgs.git
    pkgs.omnisharp-roslyn
  ];

}
