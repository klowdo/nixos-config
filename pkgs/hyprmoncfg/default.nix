# nix-update: hyprmoncfg
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "hyprmoncfg";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "crmne";
    repo = "hyprmoncfg";
    tag = "v${version}";
    hash = "sha256-LCZ1F30Ix4NnWYPI3WkL03jke9XW1cB5CWxmVSrdYYI=";
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
