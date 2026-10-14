# nix-update: herdr-spreader
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-spreader";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "yuk1ty";
    repo = "herdr-spreader";
    rev = "v${version}";
    hash = "sha256-nPuL1MUsMpgJYi0rPPBUdffp/SrI7T1fDkQBBVq/QZY=";
  };

  cargoHash = "sha256-44CbUeR1OBm9oGUf+xTMPKCebTGcvrrDA6ZjskWm8Ug=";

  doCheck = false;

  installPhase = ''
    runHook preInstall
    binary=$(find target -type f -name herdr-spreader -perm -u+x | head -n1)
    mkdir -p $out
    cp -r --no-preserve=mode . $out
    rm -rf $out/target
    install -Dm755 $binary $out/target/release/herdr-spreader
    install -Dm755 $binary $out/bin/herdr-spreader
    runHook postInstall
  '';

  passthru.herdrPlugin = {
    id = "herdr-spreader";
    name = "Spreader";
    minHerdrVersion = "0.7.0";
  };

  meta = {
    description = "Apply tmuxinator-style herdr layouts from YAML";
    homepage = "https://github.com/yuk1ty/herdr-spreader";
    license = lib.licenses.mit;
    mainProgram = "herdr-spreader";
  };
}
