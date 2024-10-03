let
  virt-nix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKaHZmLPcjFGKgi05x8W5MCtYp0IOTCxkoTYGA6BVsBm";
in
{
  "secret1.age".publicKeys = [ virt-nix ];
}


