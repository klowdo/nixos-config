# nix-update: worktrunk
_final: prev: {
  worktrunk = prev.worktrunk.overrideAttrs (_old: rec {
    version = "0.63.0";

    src = prev.fetchFromGitHub {
      owner = "max-sixty";
      repo = "worktrunk";
      tag = "v${version}";
      hash = "sha256-7tGXF3yow7FSVoA/Qs+kBX7Dw+kpNzz2lS+k1kxEM2k=";
    };

    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "worktrunk-${version}-vendor";
      hash = "sha256-MRJXbQkNN/dNxmoHDfXpod6eyHTGauOyc34ZVZd5ils=";
    };

    doCheck = false;
  });
}
