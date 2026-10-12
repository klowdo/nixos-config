{...}: {
  flake.modules.homeManager.notification = {pkgs, ...}: {
    home.packages = with pkgs; [
      libnotify
    ];
  };
}
