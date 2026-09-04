# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.20.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.20.0";
      hash = "sha256-KWvoms7O5rvfbeI13YvGIyIUZ8FAwN8XznUMYlHVA8E=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.20.0";
        hash = "sha256-KWvoms7O5rvfbeI13YvGIyIUZ8FAwN8XznUMYlHVA8E=";
      };
      hash = "sha256-1wFoapw/bQ/+9QbT/ky+bKj/hwYh4dSiWvKCTBisgrQ=";
    };
  });
}
