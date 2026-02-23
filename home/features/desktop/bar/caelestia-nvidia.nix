{
  lib,
  config,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.specialisation != {}) {
    home.packages = [
      pkgs.writeShellScriptBin
      "nvidia-smi"
      ''
        # Fake nvidia-smi for Intel integrated GPUs
        # Outputs: utilization%, temperature (matching nvidia-smi csv format)

        # Try to get Intel GPU frequency as a proxy for utilization
        freq_file="/sys/class/drm/card1/gt_cur_freq_mhz"
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

        # Use CPU temp as proxy (Intel iGPU shares die with CPU)
        temp=0
        for hwmon in /sys/class/hwmon/hwmon*/; do
          if [[ -f "$hwmon/name" ]] && grep -q "coretemp" "$hwmon/name" 2>/dev/null; then
            temp=$(cat "$hwmon/temp1_input" 2>/dev/null || echo 0)
            temp=$((temp / 1000))
            break
          fi
        done

        echo "$util, $temp"
      ''
    ];
  };
}
