# nix-update: herdr
_final: prev: {
  herdr = prev.herdr.overrideAttrs (_old: rec {
    version = "0.8.0";

    src = prev.fetchFromGitHub {
      owner = "herdrdev";
      repo = "herdr";
      tag = "v${version}";
      hash = "sha256-empFQ+hrnCh2JhOzQRWSCLV0YoZC3DXW3bY6k8YuJjk=";
    };

    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "herdr-${version}-vendor";
      hash = "sha256-E1lBgpTFZwNjeALeg/atwbDFL/XQbUnvCdX7ohbAHAc=";
    };
  });
}
