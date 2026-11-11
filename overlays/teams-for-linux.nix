# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.31.1";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.31.1";
      hash = "sha256-Cgv969FfhJmNHRsPl1nEK7Pirs68IKGkFbwjejQNji8=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.31.1";
        hash = "sha256-Cgv969FfhJmNHRsPl1nEK7Pirs68IKGkFbwjejQNji8=";
      };
      hash = "sha256-hcIOz17EQbYn9/7U2fw9H+rwGTx9+UMkSxRtj05dFCY=";
    };
  });
}
