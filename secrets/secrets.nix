let
  # uses
  klowdo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkGJ4oiQKSQc/stxvyBo1sgsNgKiH6/9EYQz7p9n8iX";
  # Hosts
  virt-nix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKaHZmLPcjFGKgi05x8W5MCtYp0IOTCxkoTYGA6BVsBm";
  dellicious = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJipK+zstuvl9BHBodjki29lMKkpZvkVuGtPc7dzxXvb";
in {
  "secret1.age".publicKeys = [virt-nix];
  "ssh.age".publicKeys = [dellicious virt-nix klowdo];
}
