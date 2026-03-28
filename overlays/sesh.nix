# nix-update: sesh
final: prev: {
  sesh = prev.sesh.overrideAttrs (oldAttrs: rec {
    version = "2.24.2";

    src = prev.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      rev = "v${version}";
      hash = "sha256-iisAIn4km/uFw2DohA2mjoYmKgDQ3lYUH284Le3xQD0=";
    };

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    vendorHash = "sha256-WHMQ7O5EZ43biR7HxjO9gUq8skFPCZVOx47NIPp5iSE=";
  });
}
