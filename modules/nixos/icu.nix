{
  flake.modules.nixos.icu = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      icu.dev
    ];
  };
}
