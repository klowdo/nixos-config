{pkgs, ...}: let
  audio-select = pkgs.writeShellScriptBin "audio-select" ./audio-select.sh;
in {
  home.packages = [
    pkgs.pulseaudio
    audio-select
  ];
}
