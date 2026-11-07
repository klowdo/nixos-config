# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.30.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.30.0";
      hash = "sha256-Of3zrdn7nvJeGTAuw3Dm35p35N4j6+WYL4/DNfL16iU=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.30.0";
        hash = "sha256-Of3zrdn7nvJeGTAuw3Dm35p35N4j6+WYL4/DNfL16iU=";
      };
      hash = "sha256-26bdyS6eNBIfP9kBMUdIU5H6/V9Jov3M7rMfhjQA+40=";
    };
  });
}
