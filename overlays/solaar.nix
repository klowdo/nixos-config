# nix-update: solaar
final: prev: {
  solaar = prev.solaar.overrideAttrs (oldAttrs: rec {
    version = "1.1.19";
    src = prev.fetchFromGitHub {
      owner = "pwr-Solaar";
      repo = "Solaar";
      tag = version;
      hash = "sha256-Z3rWGmFQmfJvsWiPgxQmfXMPHXAAiFneBaoSVIXnAV8=";
    };
    preConfigure = "";
  });
}
