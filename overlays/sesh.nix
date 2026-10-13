# nix-update: sesh
final: prev: {
  sesh = prev.sesh.overrideAttrs (oldAttrs: rec {
    version = "2.33.0";

    src = prev.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      rev = "v${version}";
      hash = "sha256-Q25fdn+1T4NOnFX5ZuIMhhRBFSj7dfjybgCj2bu3lK4=";
    };

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    vendorHash = "sha256-8CMqOlq3rAXPpzABxd2pp2DhMOvKAN+jHVZ2bLZUN0w=";
  });
}
