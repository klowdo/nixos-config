# nix-update: solaar
final: prev: {
  solaar = prev.solaar.overrideAttrs (oldAttrs: rec {
    version = "1.1.20";
    src = prev.fetchFromGitHub {
      owner = "pwr-Solaar";
      repo = "Solaar";
      tag = version;
      hash = "sha256-h/uiy0TtMicKch2cdXHur5DkvQun2sAw2HpFI7Qstqg=";
    };
    preConfigure = "";
  });
}
