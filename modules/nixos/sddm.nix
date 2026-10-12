{
  flake.modules.nixos.sddm = {pkgs, ...}: {
    services.displayManager = {
      defaultSession = "hyprland-uwsm";
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "catppuccin-macchiato";
        package = pkgs.kdePackages.sddm;
      };
    };

    environment.systemPackages = [
      pkgs.catppuccin-sddm
    ];
  };
}
