# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.16.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.16.0";
      hash = "sha256-8RwaWmi8pohUOhZp9bVNciKymvis9HRsPbOtMQ+eDGU=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.16.0";
        hash = "sha256-8RwaWmi8pohUOhZp9bVNciKymvis9HRsPbOtMQ+eDGU=";
      };
      hash = "sha256-Evepwc/hKvxkiZefhd+QTr7HKkfqhulK/dhxgx1Km5s=";
    };
  });
}
