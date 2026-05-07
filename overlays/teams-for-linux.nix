# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.9.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "f483b9cec2109656581a67284c3dbc25633ba836";
      hash = "sha256-7iQfcdHwuwfujDkOjhWF4keSiqwxymg5L1cB52EAPIY=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "f483b9cec2109656581a67284c3dbc25633ba836";
        hash = "sha256-7iQfcdHwuwfujDkOjhWF4keSiqwxymg5L1cB52EAPIY=";
      };
      hash = "sha256-iZqq47Moj1q9+0gA+rOBAbNXyUW66eHdhbDnLeWnc3k=";
    };
  });
}
