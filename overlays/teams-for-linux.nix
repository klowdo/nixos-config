# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.17.1";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.17.1";
      hash = "sha256-qI8+QqnrkGmQGweMcfyaXQnjNMf4htJAF9Gk97zL9jg=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.17.1";
        hash = "sha256-qI8+QqnrkGmQGweMcfyaXQnjNMf4htJAF9Gk97zL9jg=";
      };
      hash = "sha256-wPHap85tS3JrN4ei/HRYyzwFfVFcPkBdbY5ViEk4bwE=";
    };
  });
}
