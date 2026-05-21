# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.10.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.10.0";
      hash = "sha256-/e/NpyfcrHsgMf8tJ8VgUyCOrdfAaRH0/+kUqItd1+s=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.10.0";
        hash = "sha256-/e/NpyfcrHsgMf8tJ8VgUyCOrdfAaRH0/+kUqItd1+s=";
      };
      hash = "sha256-RvIjGXhjNqxey3zhACGj7Zd0dnmLb1IqIg/PnfEdjz0=";
    };
  });
}
