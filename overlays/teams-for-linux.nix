# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.17.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.17.0";
      hash = "sha256-JqtoX4+OjOyRNP8OlcMkHPk2ZCVNFAV0JOtZdEJp3Fk=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.17.0";
        hash = "sha256-JqtoX4+OjOyRNP8OlcMkHPk2ZCVNFAV0JOtZdEJp3Fk=";
      };
      hash = "sha256-sj0he5YLVgu6QC6BxD07MMeR2ABppEDSAvUoaR1aImM=";
    };
  });
}
