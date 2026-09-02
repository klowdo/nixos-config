# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.19.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.19.0";
      hash = "sha256-ncZ6mNXSl/GL9JMPIHhlQkTQMd1zGe1FHY2rbUc791E=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.19.0";
        hash = "sha256-ncZ6mNXSl/GL9JMPIHhlQkTQMd1zGe1FHY2rbUc791E=";
      };
      hash = "sha256-Ek6xBhG1UE8BvPqG3SF7QWyOiYMuQJWTi7iO85VUGH0=";
    };
  });
}
