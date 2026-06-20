# nix-update: teams-for-linux
final: prev: {
  teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
    version = "2.12.0";

    src = prev.fetchFromGitHub {
      owner = "IsmaelMartinez";
      repo = "teams-for-linux";
      rev = "v2.12.0";
      hash = "sha256-n9Ibno6NqiZ9W5KpPPZKD5/MTO8CKYdf/fXDf0cGsi4=";
    };

    npmDeps = prev.fetchNpmDeps {
      src = prev.fetchFromGitHub {
        owner = "IsmaelMartinez";
        repo = "teams-for-linux";
        rev = "v2.12.0";
        hash = "sha256-n9Ibno6NqiZ9W5KpPPZKD5/MTO8CKYdf/fXDf0cGsi4=";
      };
      hash = "sha256-euf/6RtAO84ZtbdhglBd6gRCcg2m6a+fhthNvFzMlho=";
    };
  });
}
