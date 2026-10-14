# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  user-config = import ./user-config.nix;
  way-displays = import ./way-displays.nix;
  junie = import ./junie.nix;
  vcstool = import ./vcstool.nix;
  hyprmoncfg = import ./hyprmoncfg.nix;
}
