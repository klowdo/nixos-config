# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.11.1";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.11.1";
      hash = "sha256-XEu0x9g2mEsmY+vZtazTOzW6KNMRbrxlPck/kPNehmo=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.11.1";
        hash = "sha256-XEu0x9g2mEsmY+vZtazTOzW6KNMRbrxlPck/kPNehmo=";
      };
      hash = "sha256-urLRj7668NX7CaDWAVxAoOg+c1TmMyvf23Je+RmFwHE=";
    };
  });
}
