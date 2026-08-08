# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.15.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.15.0";
      hash = "sha256-PYRl0Q7vsx7nKz7pkoCg3f3rRIcgCAvGiALQxHEOIjE=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.15.0";
        hash = "sha256-PYRl0Q7vsx7nKz7pkoCg3f3rRIcgCAvGiALQxHEOIjE=";
      };
      hash = "sha256-FPnkCO1zf5Ts2arOa0InC7l4esRs4AuXYlVF/OYR6AI=";
    };
  });
}
