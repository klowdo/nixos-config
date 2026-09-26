# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.23.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.23.0";
      hash = "sha256-m6Dvy+nVzwhjag89hrn6MOu1rRhVuFch/hYdKDBaP+w=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.23.0";
        hash = "sha256-m6Dvy+nVzwhjag89hrn6MOu1rRhVuFch/hYdKDBaP+w=";
      };
      hash = "sha256-MHGi5Vs8N+BKAu8hJtJG8RQuIcMh59ucJt2XR1HBvkc=";
    };
  });
}
