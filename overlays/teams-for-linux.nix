# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.27.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.27.0";
      hash = "sha256-Jf/J2xBlU/NlsHgAhvUL5qrXEr6GeqjFlOWdmJ7Vv1Y=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.27.0";
        hash = "sha256-Jf/J2xBlU/NlsHgAhvUL5qrXEr6GeqjFlOWdmJ7Vv1Y=";
      };
      hash = "sha256-g5wy73eCna1KhRh7r3KrdI4l78wQz25EKmRZLsRj4jY=";
    };
  });
}
