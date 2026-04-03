# nix-update: tmux-file-picker
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  fzf,
  fd,
  bat,
  zoxide,
  tree,
  coreutils,
  tmux,
}:
stdenvNoCC.mkDerivation {
  pname = "tmux-file-picker";
  version = "unstable-2025-03-25";

  src = fetchFromGitHub {
    owner = "raine";
    repo = "tmux-file-picker";
    rev = "ed9b36a2cd07b7c36ee4817af06859188a1cff63";
    hash = "sha256-+waMsFCSxMg+5AIfp8f9I5VtVt8Yf1UukWhjzQRFA9A=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp tmux-file-picker $out/bin/tmux-file-picker
    chmod +x $out/bin/tmux-file-picker
    wrapProgram $out/bin/tmux-file-picker \
      --prefix PATH : ${lib.makeBinPath [fzf fd bat zoxide tree coreutils tmux]}
  '';

  meta = {
    description = "Pop up fzf in tmux to quickly insert file paths";
    homepage = "https://github.com/raine/tmux-file-picker";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "tmux-file-picker";
  };
}
