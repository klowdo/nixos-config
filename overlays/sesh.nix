# nix-update: sesh
final: prev: {
  sesh = prev.sesh.overrideAttrs (oldAttrs: rec {
    version = "2.32.0";

    src = prev.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      rev = "v${version}";
      hash = "sha256-pHsRKndjE2U+Gl0oKW5d+rRST0jDEp61sXm+tRTiD3w=";
    };

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    vendorHash = "sha256-7wfg53djcty9R8WGo1H4C2VkGDraTu/n1w5c/62/YTc=";
  });
}
