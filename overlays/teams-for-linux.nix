# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.18.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.18.0";
      hash = "sha256-Rw/NYfpwNQENCEHUzKQZWrM+nxvC3rCCtXnBZmQjIz4=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.18.0";
        hash = "sha256-Rw/NYfpwNQENCEHUzKQZWrM+nxvC3rCCtXnBZmQjIz4=";
      };
      hash = "sha256-MhaUtGkIoutibiu8Flmr8QqqxSEbI8gUJE4WuX9/1Ho=";
    };
  });
}
