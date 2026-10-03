# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.24.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.24.0";
      hash = "sha256-OCIfduMAlGRtqstzyOEM3AxNFT56QFMCL7UUerF+sRU=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.24.0";
        hash = "sha256-OCIfduMAlGRtqstzyOEM3AxNFT56QFMCL7UUerF+sRU=";
      };
      hash = "sha256-KbzaFw/eSV3ygwt/ZD9Tuqksh4Ra3A4SPM3m57JjrOc=";
    };
  });
}
