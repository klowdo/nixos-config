{
  lib,
  stdenv,
  stdenvNoCC,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  python3,
  rustPlatform,
  nodejs,
}: let
  herdrPlugin = {
    pluginId,
    pluginName,
    minHerdrVersion,
    builder ? stdenvNoCC.mkDerivation,
    ...
  } @ args:
    builder (removeAttrs args ["pluginId" "pluginName" "minHerdrVersion" "builder"]
      // {
        dontBuild = args.dontBuild or true;
        installPhase =
          args.installPhase
          or ''
            runHook preInstall
            cp -r . $out
            runHook postInstall
          '';
        passthru = {inherit pluginId pluginName minHerdrVersion;};
      });
in {
  bar = herdrPlugin rec {
    pname = "herdr-bar";
    version = "0.7.3";
    pluginId = "herdr-bar";
    pluginName = "Bar";
    minHerdrVersion = "0.9.0";
    src = fetchFromGitHub {
      owner = "jeffarese";
      repo = "herdr-bar";
      rev = "e22455068e26340b6be02cec8a07707fc1f11ae1";
      hash = "sha256-LILcta5y5EilQ5B6DKjYyWlwB2k88Kx1rTZXqv/uJhw=";
    };
    postPatch = ''
      substituteInPlace herdr-plugin.toml --replace-fail '"python3"' '"${lib.getExe python3}"'
    '';
  };

  vimNavigation = herdrPlugin {
    pname = "vim-herdr-navigation";
    version = "0.1.0";
    pluginId = "vim-herdr-navigation";
    pluginName = "Vim Herdr Navigation";
    minHerdrVersion = "0.7.0";
    src = fetchFromGitHub {
      owner = "paulbkim-dev";
      repo = "vim-herdr-navigation";
      rev = "742db891e7d1f9a550b16c01dc8a6763f2b1493a";
      hash = "sha256-Yt82HBBOdY4tjvZVREpQzKoEklJY0aIYU5ZzISdf7fg=";
    };
  };

  betterWorktrees = herdrPlugin {
    builder = buildNpmPackage;
    dontBuild = false;
    pname = "herdr-better-worktrees";
    version = "0.1.0";
    pluginId = "herdr-better-worktrees";
    pluginName = "Herdr Better Worktrees";
    minHerdrVersion = "0.9.0";
    src = fetchFromGitHub {
      owner = "bearylabs";
      repo = "herdr-better-worktrees";
      rev = "fd036322f5bfb8940cc85a61f3b753d8dfc74eeb";
      hash = "sha256-h5ZayKFkkIF54H3drpJp05oKvnPI8MExry45+/UNp+g=";
    };
    npmDepsHash = "sha256-8w1BE0DQtalniHGM8Xd4pl74vbwO7qF9wonVHid0kKU=";
    postPatch = ''
      substituteInPlace herdr-plugin.toml --replace-fail '"node"' '"${lib.getExe nodejs}"'
    '';
    installPhase = ''
      runHook preInstall
      rm -rf node_modules
      cp -r . $out
      runHook postInstall
    '';
  };

  spreader = herdrPlugin rec {
    builder = rustPlatform.buildRustPackage;
    dontBuild = false;
    pname = "herdr-spreader";
    version = "0.2.1";
    pluginId = "herdr-spreader";
    pluginName = "Spreader";
    minHerdrVersion = "0.7.0";
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
  };

  annotate = herdrPlugin rec {
    builder = stdenv.mkDerivation;
    pname = "herdr-annotate";
    version = "0.9.1";
    pluginId = "annotate";
    pluginName = "Annotate";
    minHerdrVersion = "0.8.0";
    src = fetchFromGitHub {
      owner = "plannotator";
      repo = "herdr-annotate";
      rev = "ceab050b77bea07bbeabdfda5c138be8c9c5c517";
      hash = "sha256-Q/HgVn1gEAMMavWDQp8Rmz7R7qK5u0QweLkcpYL+otE=";
    };
    annotateBin = fetchurl {
      url = "https://github.com/plannotator/herdr-annotate/releases/download/rust-lite-v0.2.0/herdr-annotate-x86_64-unknown-linux-gnu";
      hash = "sha256-o+9OcnhLuoz3nlgtYCHKNPDWAPFw2jCVvMYKh7G8uUI=";
    };
    plannotatorBin = fetchurl {
      url = "https://github.com/plannotator/plannotator-tui/releases/download/v0.9.4/plannotator-tui-x86_64-unknown-linux-gnu";
      hash = "sha256-1U3GA8lfcQZ3vBPr5rJLLm6xDOdhV3r4qVoFAChit00=";
    };
    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [stdenv.cc.cc.lib];
    installPhase = ''
      runHook preInstall
      cp -r . $out
      install -Dm755 ${annotateBin} $out/bin/herdr-annotate.exe
      install -Dm755 ${plannotatorBin} $out/bin/plannotator-tui.exe
      runHook postInstall
    '';
    meta.platforms = ["x86_64-linux"];
  };
}
