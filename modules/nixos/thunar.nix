{
  flake.modules.nixos.thunar = {pkgs, ...}: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-vcs-plugin
        thunar-media-tags-plugin
      ];
    };

    services.gvfs.enable = true;
    services.tumbler.enable = true;
  };
}
