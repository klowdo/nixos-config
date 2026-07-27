# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.14.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.14.0";
      hash = "sha256-yEw0QJx5uztxH3KmhePR40/LtCHWdzZ+WHNCXisG+7U=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.14.0";
        hash = "sha256-yEw0QJx5uztxH3KmhePR40/LtCHWdzZ+WHNCXisG+7U=";
      };
      hash = "sha256-rY2J6Q7dsY90TaVpcC2xWbMjIZ6YYF/Pl32pNL+pi9s=";
    };
  });
}
