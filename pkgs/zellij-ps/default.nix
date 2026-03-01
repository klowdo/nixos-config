{
  lib,
  fish,
  fd,
  fzf,
  makeWrapper,
  zellij,
  fetchFromGitea,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "zellij-ps";
  version = "0.1.0";

  src = fetchFromGitea {
    domain = "code.m3tam3re.com";
    owner = "m3tam3re";
    repo = "helper-scripts";
    rev = "08a3217b83391c1110545c1ee3161eecd5dbe5e9";
    sha256 = "1sc4i58mwcg3qsq0wwl5rvk08ykbxc497bq7mrxiirndsarskby7";
  };

  buildInputs = [];
  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    mkdir -p $out/bin
    cp zellij-ps.fish $out/bin/zellij-ps
    wrapProgram $out/bin/zellij-ps \
      --prefix PATH : ${lib.makeBinPath [fish fd fzf zellij]}
  '';
  meta = with lib; {
    description = "A small project script for zellij";
    homepage = "https://code.m3tam3re.com/m3tam3re/helper-scripts";
    license = licenses.mit;
    maintainers = with maintainers; [m3tam3re];
    platforms = platforms.unix;
  };
}
