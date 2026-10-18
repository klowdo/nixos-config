# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.26.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.26.0";
      hash = "sha256-+zs7loau1+n3sHaj41xjbU/JhXmS9SHmaF3KRoKoIZk=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.26.0";
        hash = "sha256-+zs7loau1+n3sHaj41xjbU/JhXmS9SHmaF3KRoKoIZk=";
      };
      hash = "sha256-B2GORqbBjScr0o84bjxZjTwYQ2NQrI66h8yYE8qXgq4=";
    };
  });
}
