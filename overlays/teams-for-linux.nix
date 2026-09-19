# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.22.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.22.0";
      hash = "sha256-FcAYtEX6SjXeJfxwCq9uSD2dOJt+WkBTQnP+SmSy5bY=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.22.0";
        hash = "sha256-FcAYtEX6SjXeJfxwCq9uSD2dOJt+WkBTQnP+SmSy5bY=";
      };
      hash = "sha256-t5Mz3X/VnMmEuy/dGJC17/Wk8WwLdmF0rVQ445T5YP4=";
    };
  });
}
