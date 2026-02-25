{
  imports = [
    ../common/optional/disko/uefi-btrfs.nix
  ];

  disko-btrfs = {
    enable = true;
    device = "/dev/nvme0n1";
    swapSize = "64G";
    enableEncryption = true;
    enableTpm2 = true;
    enablePersist = true;
    enableHibernation = false;
    hibernationResumeOffset = null;
  };
}
