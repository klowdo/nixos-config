# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.25.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.25.0";
      hash = "sha256-SZdTonS/D2OUX9jaeRGopU1drfIlwMMYLKIe+g+W6UQ=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.25.0";
        hash = "sha256-SZdTonS/D2OUX9jaeRGopU1drfIlwMMYLKIe+g+W6UQ=";
      };
      hash = "sha256-i7vX/JwJCx28vQlFIPc1gt8EGWdOBBSTR7p9xHaxvrU=";
    };
  });
}
