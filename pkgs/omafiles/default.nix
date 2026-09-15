# nix-update: omafiles
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6,
  glib,
  python3,
  bash,
  bzip2,
  coreutils,
  ffmpegthumbnailer,
  findutils,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  libnotify,
  p7zip,
  udisks2,
  unzip,
  util-linux,
  xdg-utils,
  xz,
  zstd,
}: let
  # scripts/dbus-{app-open,filemanager1,filechooser}.py talk to the session bus
  # through GLib/GDBus via PyGObject.
  pythonEnv = python3.withPackages (ps: [ps.pygobject3]);

  # Helpers under share/omafiles/scripts/runtime are spawned by the QML side, so
  # they inherit the wrapper's PATH: list-mounts (findmnt/lsblk/udisksctl),
  # mount-iso (udisksctl), list-archive (unzip/7z/tar), thumbnail-video
  # (ffmpegthumbnailer). backend/Notifier shells out to notify-send and the
  # "open with" path to xdg-mime/xdg-open. `unrar` is deliberately left out
  # (unfree), so listing .rar contents is the one archive format that stays
  # unsupported; tracker3/plocate are optional too - without them global search
  # falls back to the built-in recursive walk.
  runtimeDeps = [
    bash
    bzip2
    coreutils
    ffmpegthumbnailer
    findutils
    gnugrep
    gnused
    gnutar
    gzip
    libnotify
    p7zip
    udisks2
    unzip
    util-linux
    xdg-utils
    xz
    zstd
  ];
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "omafiles";
    version = "0.9.0";

    src = fetchFromGitHub {
      owner = "Percius04";
      repo = "omafiles";
      tag = "v${finalAttrs.version}";
      hash = "sha256-ZPnMoL1o2CYU5EYYsgJxqH79dapdd6/r//mlZ1f3wWI=";
    };

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      qt6.wrapQtAppsHook
    ];

    buildInputs = [
      glib # gio-2.0, via pkg_check_modules
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtimageformats # webp/avif thumbnails
      qt6.qtsvg
      qt6.qtwayland
      qt6.qtwebengine # only for Qt6::Pdf (QPdfDocument, PDF thumbnails)
    ];

    # Upstream targets a no-root per-user install: every destination is its own
    # cache variable defaulting under $HOME/.local, and CMAKE_INSTALL_PREFIX is
    # ignored. main.cpp bakes the data/QML dirs into the binary
    # (resolveResourceDir/addImportPaths), so they have to point at $out.
    cmakeFlags = [
      (lib.cmakeFeature "OMAFILES_BIN_INSTALL_DIR" "${placeholder "out"}/bin")
      (lib.cmakeFeature "OMAFILES_DATA_INSTALL_DIR" "${placeholder "out"}/share")
      (lib.cmakeFeature "OMAFILES_QML_INSTALL_DIR" "${placeholder "out"}/${qt6.qtbase.qtQmlPrefix}")
    ];

    postPatch = ''
      # The .desktop launcher goes through open-path.sh, which hardcodes the
      # per-user install location of the binary.
      substituteInPlace scripts/open-path.sh \
        --replace-fail '$HOME/.local/bin/omafiles' "$out/bin/omafiles"

      # D-Bus activation does not necessarily see the user profile in PATH, and
      # the ~/.local/bin fallback never exists here.
      substituteInPlace scripts/dbus-app-open.py scripts/dbus-filechooser.py scripts/dbus-filemanager1.py \
        --replace-fail 'shutil.which("omafiles") or str(Path.home() / ".local" / "bin" / "omafiles")' "\"$out/bin/omafiles\"" \
        --replace-fail '#!/usr/bin/python3' '#!${pythonEnv}/bin/python3'

      # On startup the app runs install-integrations.sh, which imperatively
      # rewrites ~/.local/share/applications, the session D-Bus services and
      # the xdg-desktop-portal configuration. All of that is declarative in the
      # home-manager module instead, so drop the self-registration.
      substituteInPlace core/AppBindings.qml \
        --replace-fail 'Backend.Detached.run([Paths.resourceDir + "/scripts/runtime/scripts/install-integrations.sh"])' \
                       '// self-registration removed: handled declaratively by home-manager'
    '';

    qtWrapperArgs = [
      "--prefix PATH : ${lib.makeBinPath runtimeDeps}"
    ];

    meta = {
      description = "Keyboard-first, tileable Qt6 file manager";
      longDescription = ''
        Omafiles is a native Qt6/QML file manager built around vim-style
        keyboard navigation, multiple persistent panels, indexed global search,
        native previews and thumbnails, and Wayland/Hyprland integration.
      '';
      homepage = "https://github.com/Percius04/omafiles";
      license = lib.licenses.mit;
      maintainers = [];
      platforms = lib.platforms.linux;
      mainProgram = "omafiles";
    };
  })
