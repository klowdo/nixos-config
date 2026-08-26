# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.18.1";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.18.1";
      hash = "sha256-dKTsilBu57Z8XcoyiviuOW/jfIqnbfiBZFl2hpvaiIc=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.18.1";
        hash = "sha256-dKTsilBu57Z8XcoyiviuOW/jfIqnbfiBZFl2hpvaiIc=";
      };
      hash = "sha256-/1CPHy+gBVc79GYLAlfzSEOckM7UxyFblBQO9lZoMTw=";
    };
  });
}
