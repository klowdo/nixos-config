# nix-update: sesh
final: prev: {
  sesh = prev.sesh.overrideAttrs (oldAttrs: rec {
    version = "2.31.0";

    src = prev.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      rev = "v${version}";
      hash = "sha256-SV7BSrBS3NDVFACG5vShCECJlQ4+9rIdOxmINR8J3ms=";
    };

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    vendorHash = "sha256-81PNc4Gt3wzGyihRWOtJFlIiA7HieZyGh/4gpFHVlYA=";
  });
}
