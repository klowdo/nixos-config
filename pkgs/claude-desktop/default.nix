# nix-update: claude-desktop
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libcap_ng,
  libGL,
  libglvnd,
  libseccomp,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  xdg-utils,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxscrnsaver,
  libxtst,
}: let
  version = "1.26832.0";
  arch =
    {
      x86_64-linux = "amd64";
      aarch64-linux = "arm64";
    }
    .${
      stdenv.hostPlatform.system
    }
    or (throw "claude-desktop: unsupported system ${stdenv.hostPlatform.system}");
  hashes = {
    amd64 = "sha256-K8bw1BCbtDswdpbhEo31P785PvmPlHp4aZSGQkUCRdc=";
    arm64 = "sha256-woEP1oskEPgyboCkVXPS8+e81RqvgQ2a6S08CXih1VM=";
  };
in
  stdenv.mkDerivation {
    pname = "claude-desktop";
    inherit version;

    src = fetchurl {
      url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_${arch}.deb";
      hash = hashes.${arch};
    };

    nativeBuildInputs = [dpkg autoPatchelfHook makeWrapper wrapGAppsHook3];

    buildInputs = [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libcap_ng
      libdrm
      libnotify
      libseccomp
      libsecret
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxscrnsaver
      libxtst
    ];

    runtimeDependencies = [systemd libglvnd];

    unpackCmd = "dpkg-deb -x $curSrc source";
    sourceRoot = "source";

    dontConfigure = true;
    dontBuild = true;
    dontWrapGApps = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share
      cp -r usr/lib/claude-desktop $out/libexec
      cp -r usr/share/applications usr/share/icons $out/share/

      runHook postInstall
    '';

    preFixup = ''
      makeWrapper $out/libexec/claude-desktop $out/bin/claude-desktop \
        "''${gappsWrapperArgs[@]}" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libGL vulkan-loader libpulseaudio]} \
        --prefix PATH : ${lib.makeBinPath [xdg-utils]} \
        --add-flags "--disable-setuid-sandbox"
    '';

    meta = {
      description = "Desktop application for Claude.ai";
      homepage = "https://claude.com/download";
      license = lib.licenses.unfree;
      mainProgram = "claude-desktop";
      platforms = ["x86_64-linux" "aarch64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
