# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.11.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.11.0";
      hash = "sha256-W902oggHIDngdJ+0+MTpTLJhTU7vd3Dizds+EKCc1CI=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.11.0";
        hash = "sha256-W902oggHIDngdJ+0+MTpTLJhTU7vd3Dizds+EKCc1CI=";
      };
      hash = "sha256-mtd7T1gS+sKzLLL20Ms8n30r9/J2LbTO9CzowTCy4ZM=";
    };
  });
}
