# nix-update: sesh
final: prev: {
  sesh = prev.sesh.overrideAttrs (oldAttrs: rec {
    version = "2.26.0";

    src = prev.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      rev = "v${version}";
      hash = "sha256-8Z3Ot2BAxSVxzXWPpbstcd1Fklwg8b5X2qEJ1lfiCqg=";
    };

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    vendorHash = "sha256-9IiDp/HaxXQAyNzuVBLiO+oIijBbdKBjssCmj8WV9V4=";
  });
}
