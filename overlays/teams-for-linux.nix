# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.29.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.29.0";
      hash = "sha256-msMbWGKWOEIryu6c0sg+gRN/nfLd3yyr/+tjyVAyr/0=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.29.0";
        hash = "sha256-msMbWGKWOEIryu6c0sg+gRN/nfLd3yyr/+tjyVAyr/0=";
      };
      hash = "sha256-i3d9wShtiWXu0W+1iG20MRVwTFn5BIQr1PXdRaGoczM=";
    };
  });
}
