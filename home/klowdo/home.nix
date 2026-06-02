{inputs, ...}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  userConfig = {
    username = "klowdo";
    fullName = "Felix Svensson";
    email = "klowdo.fs@gmail.com";
  };

  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "macchiato";
  };

  home = {
    stateVersion = "26.05";

    file = {
      ".face".source = ../../lib/felix_evolve.jpg;
      ".face.icon".source = ../../lib/felix_evolve.jpg;
      ".ssh/id_ed25519.pub".source = ./keys/id_ed25519.pub;
    };
  };

  systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;
}
