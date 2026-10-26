# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.28.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.28.0";
      hash = "sha256-35MzasxIBLIS2p/4L7Z6XU/Y8sahLzuoaa6zlPh5Hhk=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.28.0";
        hash = "sha256-35MzasxIBLIS2p/4L7Z6XU/Y8sahLzuoaa6zlPh5Hhk=";
      };
      hash = "sha256-XGZjPvexha6mBZvjSpPJCLDY8yVUyDllD171+W22Tx8=";
    };
  });
}
