{
  # Service modules unique to this directory
  # Common service modules are in ../optional/*.nix
  imports = [
    ./worldstream/strongSwan.nix
    ./worldstream/strongSwan-swanctl.nix
  ];
}
