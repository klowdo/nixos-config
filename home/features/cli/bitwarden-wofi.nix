{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.bitwarden-wofi;

  # Bitwarden CLI integration with Wofi for password management
  wofi-bitwarden = pkgs.writeShellScriptBin "wofi-bitwarden" ''
    # Prevent multiple instances
    LOCK_FILE="/tmp/wofi-bitwarden.lock"
    if [[ -f "$LOCK_FILE" ]]; then
      exit 0
    fi
    trap "rm -f $LOCK_FILE" EXIT
    touch "$LOCK_FILE"

    WOFI_HEIGHT="400"
    WOFI_WIDTH="800"

    # Check if bitwarden-cli is available
    if ! command -v bw &> /dev/null; then
      notify-send "Bitwarden Error" "Bitwarden CLI not found" -t 3000
      exit 1
    fi

    # Check if user is logged in
    if ! bw status | grep -q '"status":"unlocked"'; then
      if bw status | grep -q '"status":"locked"'; then
        # Vault is locked, prompt for password
        master_password=$(echo "" | wofi --dmenu --password --prompt "Master Password:" --lines 1 --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT")
        if [[ -z "$master_password" ]]; then
          exit 0
        fi
        
        # Unlock vault
        if ! echo "$master_password" | bw unlock --raw > /tmp/bw_session 2>/dev/null; then
          notify-send "Bitwarden Error" "Failed to unlock vault" -t 3000
          rm -f /tmp/bw_session
          exit 1
        fi
        export BW_SESSION=$(cat /tmp/bw_session)
        rm -f /tmp/bw_session
      else
        # Not logged in
        notify-send "Bitwarden Error" "Please login first: bw login" -t 3000
        exit 1
      fi
    fi

    # Get all items from vault
    items=$(bw list items --session "$BW_SESSION" 2>/dev/null)
    if [[ $? -ne 0 ]] || [[ -z "$items" ]]; then
      notify-send "Bitwarden Error" "Failed to fetch items from vault" -t 3000
      exit 1
    fi

    # Parse items and create menu options
    menu_options=$(echo "$items" | jq -r '.[] | select(.type == 1) | "🔑 " + .name + " (" + (.login.username // "no username") + ")"' 2>/dev/null)
    
    if [[ -z "$menu_options" ]]; then
      notify-send "Bitwarden" "No login items found in vault" -t 3000
      exit 0
    fi

    # Show item selection menu
    selected=$(echo "$menu_options" | wofi --dmenu --prompt "Select Account:" --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT")
    
    if [[ -z "$selected" ]]; then
      exit 0
    fi

    # Extract item name from selection
    item_name=$(echo "$selected" | sed 's/🔑 \(.*\) (.*/\1/')

    # Get the specific item
    item_data=$(echo "$items" | jq -r --arg name "$item_name" '.[] | select(.name == $name and .type == 1)' 2>/dev/null)
    
    if [[ -z "$item_data" ]]; then
      notify-send "Bitwarden Error" "Item not found" -t 3000
      exit 1
    fi

    # Show action menu
    action_menu="👤 Copy Username
🔒 Copy Password
🌐 Copy URL
📋 Show Details"

    action=$(echo "$action_menu" | wofi --dmenu --prompt "Action for $item_name:" --lines 4 --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT")

    case "$action" in
      "👤 Copy Username")
        username=$(echo "$item_data" | jq -r '.login.username // empty')
        if [[ -n "$username" ]]; then
          echo -n "$username" | wl-copy
          notify-send "Bitwarden" "Username copied to clipboard" -t 2000
        else
          notify-send "Bitwarden" "No username found" -t 2000
        fi
        ;;
      "🔒 Copy Password")
        password=$(echo "$item_data" | jq -r '.login.password // empty')
        if [[ -n "$password" ]]; then
          echo -n "$password" | wl-copy
          notify-send "Bitwarden" "Password copied to clipboard" -t 2000
          # Clear clipboard after 45 seconds
          (sleep 45 && echo -n "" | wl-copy) &
        else
          notify-send "Bitwarden" "No password found" -t 2000
        fi
        ;;
      "🌐 Copy URL")
        url=$(echo "$item_data" | jq -r '.login.uris[0].uri // empty' 2>/dev/null)
        if [[ -n "$url" ]]; then
          echo -n "$url" | wl-copy
          notify-send "Bitwarden" "URL copied to clipboard" -t 2000
        else
          notify-send "Bitwarden" "No URL found" -t 2000
        fi
        ;;
      "📋 Show Details")
        username=$(echo "$item_data" | jq -r '.login.username // "N/A"')
        url=$(echo "$item_data" | jq -r '.login.uris[0].uri // "N/A"' 2>/dev/null)
        notes=$(echo "$item_data" | jq -r '.notes // "N/A"' | head -c 100)
        
        details="Name: $item_name
Username: $username
URL: $url
Notes: $notes"
        
        echo "$details" | wofi --dmenu --prompt "Details:" --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT"
        ;;
    esac
  '';
in {
  options.features.cli.bitwarden-wofi = {
    enable = mkEnableOption "Bitwarden CLI integration with Wofi";
  };

  config = mkIf cfg.enable {
    # Install script and required dependencies
    home.packages = with pkgs; [
      wofi-bitwarden
      bitwarden-cli
      jq # for JSON parsing
      wl-clipboard # for clipboard operations
      libnotify # for notifications
    ];
  };
}