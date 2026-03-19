{
  stdenv,
  lib,
  fetchFromGitLab,
}:
stdenv.mkDerivation {
  pname = "nvidia-greenboost";
  version = "2.5";

  src = fetchFromGitLab {
    owner = "IsolatedOctopi";
    repo = "nvidia_greenboost";
    rev = "v2.5";
    hash = "sha256-Qln1Ba4ujtVwUuNPQ+6ADSazcG16XwJ6LQDHcvlqXKg=";
  };

  buildPhase = ''
    runHook preBuild
    make shim
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D libgreenboost_cuda.so $out/lib/libgreenboost_cuda.so

    mkdir -p $out/bin
    cat > $out/bin/greenboost-run << 'SCRIPT'
    #!/bin/sh
    export LD_PRELOAD="@out@/lib/libgreenboost_cuda.so:$LD_PRELOAD"
    exec "$@"
    SCRIPT
    substituteInPlace $out/bin/greenboost-run --replace-warn "@out@" "$out"
    chmod +x $out/bin/greenboost-run

    runHook postInstall
  '';

  meta = with lib; {
    description = "NVIDIA GreenBoost userspace CUDA shim for GPU VRAM extension";
    homepage = "https://gitlab.com/IsolatedOctopi/nvidia_greenboost";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
