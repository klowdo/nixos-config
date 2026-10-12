{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.specialisation != {}) {
    boot.extraModprobeConfig = ''
      blacklist nouveau
      options nouveau modeset=0
    '';

    services.udev.extraRules = ''
      # Remove NVIDIA USB xHCI Host Controller devices, if present
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

      # Remove NVIDIA USB Type-C UCSI devices, if present
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

      # Remove NVIDIA Audio devices, if present
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

      # Remove NVIDIA VGA/3D controller devices
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
    '';
    boot.blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
    ];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nvidia-smi" ''
         if [[ "$*" == *"--query-gpu=name"* ]]; then
           ${pkgs.pciutils}/bin/lspci 2>/dev/null | grep -i 'vga\|3d\|display' | head -1 | sed 's/.*: //'
           exit 0
         fi
        max_freq_file="/sys/class/drm/card1/gt_max_freq_mhz"

         if [[ -f "$freq_file" && -f "$max_freq_file" ]]; then
           cur=$(cat "$freq_file" 2>/dev/null || echo 0)
           max=$(cat "$max_freq_file" 2>/dev/null || echo 1)
           if [[ "$max" -gt 0 ]]; then
             util=$((cur * 100 / max))
           else
             util=0
           fi
         else
           util=0
         fi

         temp=0
         for hwmon in /sys/class/hwmon/hwmon*/; do
           if [[ -f "$hwmon/name" ]] && grep -q "coretemp" "$hwmon/name" 2>/dev/null; then
             temp=$(cat "$hwmon/temp1_input" 2>/dev/null || echo 0)
             temp=$((temp / 1000))
             break
           fi
         done

         echo "$util, $temp"
      '')
    ];
  };
}
