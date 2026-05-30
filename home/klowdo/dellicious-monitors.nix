{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hyprdynamicmonitors.homeManagerModules.hyprdynamicmonitors
  ];

  home = {
    packages = [pkgs.upower];
    hyprdynamicmonitors.enable = false;
  };

  services.hyprmoncfg.enable = true;
}
