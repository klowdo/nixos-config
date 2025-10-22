# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files her
  way-displays = import ./way-displays.nix;
  claudia = import ./claudia.nix;
  vivid-stub = import ./vivid-stub.nix;
}
# {lib, ...}: {
#   imports = lib.custom.scanPaths ./.;
# }

