{pkgs, ...}: let
  audio-select-script = pkgs.writeShellScriptBin "audio-select-script" ./audio-select.sh;
  audio-select-config = ./audio-config.yml;
  audio-select = pkgs.writeShellApplication {
    name = "audio-select";
    runtimeInputs = with pkgs; [ponymix yq-go];
    text = ''
      ${audio-select-script}/bin/audio-select-script ${audio-select-config}
    '';
  };
in {
  home.packages = [
    pkgs.pulseaudio
    audio-select
  ];
}
