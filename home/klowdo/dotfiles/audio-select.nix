{pkgs, ...}: let
  audio-select-script = pkgs.writeShellScriptBin "audio-select-script" ./audio-select-new.sh;
  audio-select = pkgs.writeShellApplication {
    name = "audio-select";
    runtimeInputs = with pkgs; [ponymix yq-go];
    text = ''
      ${audio-select-script}/bin/audio-select-script ${./audio-config.yml}
    '';
  };
in {
  home.packages = [
    pkgs.pulseaudio
    audio-select
  ];
}
