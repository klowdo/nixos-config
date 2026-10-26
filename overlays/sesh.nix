# nix-update: sesh
final: prev: {
  sesh = prev.sesh.overrideAttrs (oldAttrs: rec {
    version = "2.34.0";

    src = prev.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      rev = "v${version}";
      hash = "sha256-wuG+vcHrMXkHqUUBQrQ5F+DcpszfX/1c+0fHzYe8t/w=";
    };

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    vendorHash = "sha256-8CMqOlq3rAXPpzABxd2pp2DhMOvKAN+jHVZ2bLZUN0w=";
  });
}
