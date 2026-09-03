# nix-update: hyprmoncfg
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "hyprmoncfg";
  version = "1.17.1";

  src = fetchFromGitHub {
    owner = "crmne";
    repo = "hyprmoncfg";
    tag = "v${version}";
    hash = "sha256-h2TNsEascI1WP1g5dCDfiBdLnZePRjypToMqHHIg9PI=";
  };

  vendorHash = "sha256-gQbjvdKtO0hCXrs9RnWo1s0YeHf5W9t+8AgS2ELXlPo=";

  subPackages = [
    "cmd/hyprmoncfg"
    "cmd/hyprmoncfgd"
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Hyprland monitor profile manager with TUI and auto-switching daemon";
    homepage = "https://github.com/crmne/hyprmoncfg";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "hyprmoncfg";
  };
}
