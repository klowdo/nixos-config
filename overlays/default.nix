# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });


    neovim = inputs.kixvim.packages.${prev.stdenv.hostPlatform.system}.default;

    pulseaudio-dlna = prev.pulseaudio-dlna.overrideAttrs (oldAttrs: {
      buildInputs =
        (oldAttrs.buildInputs or [])
        ++ [
          prev.gobject-introspection
        ];
      nativeBuildInputs =
        (oldAttrs.nativeBuildInputs or [])
        ++ [
          prev.wrapGAppsHook3
          prev.gobject-introspection
        ];
    });

    strongswan = prev.strongswan.overrideAttrs (oldAttrs: {
      configureFlags =
        oldAttrs.configureFlags
        ++ [
          "--enable-bypass-lan"
        ];
    });

    # Slack with native Wayland support - override installPhase to use explicit wayland
    slack = prev.slack.overrideAttrs (oldAttrs: {
      installPhase =
        builtins.replaceStrings
        ["--ozone-platform-hint=auto"]
        ["--ozone-platform=wayland"]
        oldAttrs.installPhase;
    });

    dotnet-combined = with final.unstable.dotnetCorePackages;
      (combinePackages [
        # sdk_8_0_3xx
        # sdk_9_0
        final.unstable.dotnet-sdk_8
        final.unstable.dotnet-sdk_9
      ])
      .overrideAttrs (_finalAttrs: previousAttrs: {
        # This is needed to install workload in $HOME
        # https://discourse.nixos.org/t/dotnet-maui-workload/20370/2
        postBuild =
          (previousAttrs.postBuild or '''')
          + ''
             for i in $out/sdk/*
             do
               i=$(basename $i)
               length=$(printf "%s" "$i" | wc -c)
               substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
               i="$substring""00"
               mkdir -p $out/metadata/workloads/''${i/-*}
               touch $out/metadata/workloads/''${i/-*}/userlocal
            done
          '';
      });
  } // (inputs.claude-code.overlays.default final prev); # Claude Code overlay (auto-updates within 1 hour)

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
