{
  stdenv,
  lib,
  fetchFromGitLab,
  kernel,
}:
stdenv.mkDerivation {
  pname = "nvidia-greenboost-module";
  version = "2.5";

  src = fetchFromGitLab {
    owner = "IsolatedOctopi";
    repo = "nvidia_greenboost";
    rev = "v2.5";
    hash = "sha256-Qln1Ba4ujtVwUuNPQ+6ADSazcG16XwJ6LQDHcvlqXKg=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  KDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

  postPatch = ''
    echo 'MODULE_IMPORT_NS(DMA_BUF);' >> greenboost.c
  '';

  buildPhase = ''
    runHook preBuild
    make module KDIR=$KDIR
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D greenboost.ko $out/lib/modules/${kernel.modDirVersion}/extra/greenboost.ko
    runHook postInstall
  '';

  meta = with lib; {
    description = "NVIDIA GreenBoost kernel module for GPU VRAM extension";
    homepage = "https://gitlab.com/IsolatedOctopi/nvidia_greenboost";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
