{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    appimage-tools
  ];
}
