# nix-update: gh-enhance
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "gh-enhance";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = "gh-enhance";
    rev = "v${version}";
    hash = "sha256-W7EyYi/Ycyu9WcWxPexJJTGkcHWveY4xsySfEZKy5/c=";
  };

  vendorHash = "sha256-gPs05ByMdsfjjY4rVp8UYX9OkfJ1BkUl4ywiFIBen8w=";

  ldflags = ["-s" "-w" "-X=github.com/dlvhdr/gh-enhance/internal/version.Version=${version}"];

  doCheck = false;

  meta = {
    description = "Terminal UI for GitHub Actions";
    homepage = "https://github.com/dlvhdr/gh-enhance";
    license = lib.licenses.mit;
    mainProgram = "gh-enhance";
  };
}
