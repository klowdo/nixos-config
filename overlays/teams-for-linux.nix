# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.13.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.13.0";
      hash = "sha256-30jt23bsJ1XE2gclRg06AM+mk1IrerNnkbWVDRfjqHo=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.13.0";
        hash = "sha256-30jt23bsJ1XE2gclRg06AM+mk1IrerNnkbWVDRfjqHo=";
      };
      hash = "sha256-pz2htdFmczmZJtcrpI/X0nUUF++x2vtcYZiTWjEYglo=";
    };
  });
}
