{pkgs, ...}: {
  #todo: add option
  services.udev = {
    packages = with pkgs; [
      qmk-udev-rules # the only relevant
      via
      vial
    ]; # packages
  }; # udev
}
