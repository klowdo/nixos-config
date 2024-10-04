{inputs, ...}: {
  imports = [
    ./bat.nix
    ./audio-select.nix
  ];

  # https://code.m3tam3re.com/m3tam3re/nixcfg/commit/aa7dcee6963ae79ca47e77585657cda2838cbf0c#diff-ba9954fd317cafc9c3f2c06b7821686e0f801979
  # https://www.youtube.com/watch?v=HEt6b418Ueo
  # home.file.".config/nvim" = {
  #   source = "${inputs.dotfiles}/nvim";
  #   recursive = true;
  # };
}
