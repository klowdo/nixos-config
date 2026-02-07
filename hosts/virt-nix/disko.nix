{
  imports = [
    ../common/optional/disko/uefi-btrfs.nix
  ];

  disko-btrfs = {
    enable = true;
    device = "/dev/sda";
    swapSize = "4G";
    enableEncryption = false;
    enablePersist = true;
  };
}
