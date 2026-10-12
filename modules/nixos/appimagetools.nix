{
  flake.modules.nixos.appimagetools = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      appimage-tools
    ];
  };
}
