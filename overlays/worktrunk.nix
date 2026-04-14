# nix-update: worktrunk
_final: prev: {
  worktrunk = prev.worktrunk.overrideAttrs (_old: rec {
    version = "0.37.0";

    src = prev.fetchFromGitHub {
      owner = "max-sixty";
      repo = "worktrunk";
      tag = "v${version}";
      hash = "sha256-z+Wb0xgu15cSSYB3hPhp6qVwUUXmLJcP788LiQLowqs=";
    };

    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "worktrunk-${version}-vendor";
      hash = "sha256-nBbLlM4Y5IOSeGrgiu7Bm9PcTSarXiqFbC2RnTrhWeE=";
    };
  });
}
