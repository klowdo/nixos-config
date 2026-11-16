# nix-update: hyprmoncfg
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "hyprmoncfg";
  version = "1.29.1";

  src = fetchFromGitHub {
    owner = "crmne";
    repo = "hyprmoncfg";
    tag = "v${version}";
    hash = "sha256-vPUrk0C5fHznNJYGujZMOCNuR/5vJqzGRbRktDEH+XE=";
  };

  vendorHash = "sha256-wpSKWfc8EO+luoICZmxsrQitBD2M+1zPDNukLCF0+/Y=";

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
