# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.14.1";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.14.1";
      hash = "sha256-0urL/M7XBBPB+RiLglUx0CQUii+Fji1dXurha/2URug=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.14.1";
        hash = "sha256-0urL/M7XBBPB+RiLglUx0CQUii+Fji1dXurha/2URug=";
      };
      hash = "sha256-F8FxTkVDfCLp0ukNm9/ixWtglYRiJt9+va6qJdB06qI=";
    };
  });
}
