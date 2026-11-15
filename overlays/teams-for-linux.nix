# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.32.1";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.32.1";
      hash = "sha256-9Fv17P8lObmD21f/1ddAHVEh6jWW80kq3O21HiHSq1Q=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.32.1";
        hash = "sha256-9Fv17P8lObmD21f/1ddAHVEh6jWW80kq3O21HiHSq1Q=";
      };
      hash = "sha256-sf6Yc4pgbXZQaEitEUb2i6x+ANWqoU7polPHIcBc29E=";
    };
  });
}
