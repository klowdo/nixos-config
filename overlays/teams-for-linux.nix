# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.21.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.21.0";
      hash = "sha256-I1g24QPamdFXz5mExmWxZFRyfs/LJb/W1bbwKFEyYAw=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.21.0";
        hash = "sha256-I1g24QPamdFXz5mExmWxZFRyfs/LJb/W1bbwKFEyYAw=";
      };
      hash = "sha256-zZ99SLlj1DD0brrNj5Vfjp7MlVau0bE1pZSXo4fYUNk=";
    };
  });
}
