{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.virtualization;
in {
  options.extraServices.virtualization = {
    enable = mkEnableOption "enable QEMU/KVM virtualization with virt-manager";
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu;
        runAsRoot = true;
        swtpm.enable = true;
        vhostUserPackages = [pkgs.virtiofsd];
        verbatimConfig = ''
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/dri/renderD128",
            "/dev/dri/card0"
          ]
        '';
      };
    };

    virtualisation.spiceUSBRedirection.enable = true;

    networking.firewall.trustedInterfaces = ["virbr0"];

    programs.virt-manager.enable = true;

    services.spice-vdagentd.enable = true;

    environment.systemPackages = with pkgs; [
      spice-gtk
      virt-viewer
    ];
  };
}
