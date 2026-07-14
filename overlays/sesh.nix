# nix-update: sesh
final: prev: {
  sesh = prev.sesh.overrideAttrs (oldAttrs: rec {
    version = "2.27.0";

    src = prev.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      rev = "v${version}";
      hash = "sha256-py4Dok8nyyxqenaY5Clhik0W8vo3dsw2EhzUZxQtA38=";
    };

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    vendorHash = "sha256-9IiDp/HaxXQAyNzuVBLiO+oIijBbdKBjssCmj8WV9V4=";
  });
}
