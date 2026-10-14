# nix-update: terminal-browser
{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  writeText,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  systemd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "terminal-browser";
  version = "0.13.4";

  src = fetchzip {
    url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v${finalAttrs.version}/terminal-browser-linux-x64.tar.gz";
    hash = "sha256-K+bYSUHVw+dnbOZPt4l8bM1RAADJnQMVcRPWke8Y8eE=";
  };

  nativeBuildInputs = [autoPatchelfHook];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    systemd
  ];

  dontBuild = true;

  installPhase = let
    manifest = writeText "herdr-plugin.toml" ''
      id = "zenbu-labs.terminal-browser"
      name = "Terminal Browser"
      version = "${finalAttrs.version}"
      min_herdr_version = "0.8.2"
      description = "Open a browser inside herdr"
      platforms = ["linux"]

      [[actions]]
      id = "open-split"
      title = "Open terminal-browser (right split)"
      contexts = ["global"]
      command = ["bash", "open-split.sh"]
    '';
  in ''
    runHook preInstall
    mkdir -p $out/lib/terminal-browser $out/bin
    cp -r . $out/lib/terminal-browser
    ln -s $out/lib/terminal-browser/bin/terminal-browser $out/bin/terminal-browser
    cp ${manifest} $out/herdr-plugin.toml
    printf '#!/bin/sh\nexec %s/bin/terminal-browser open --split right\n' "$out" > $out/open-split.sh
    chmod +x $out/open-split.sh
    runHook postInstall
  '';

  passthru.herdrPlugin = {
    id = "zenbu-labs.terminal-browser";
    name = "Terminal Browser";
    minHerdrVersion = "0.8.2";
  };

  meta = {
    description = "Browser that runs inside the terminal";
    homepage = "https://github.com/zenbu-labs/terminal-browser";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "terminal-browser";
  };
})
