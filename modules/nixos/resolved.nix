# https://github.com/mrkuz/nixos/blob/master/modules/nixos/resolved.nix
{
  flake.modules.nixos.resolved = {
    services.resolved.enable = true;
  };
}
