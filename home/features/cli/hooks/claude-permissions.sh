#!/usr/bin/env bash

# Claude Code Permission Preferences Manager
PREFERENCES_FILE="$HOME/.claude/permission-preferences"

show_help() {
    echo "Claude Code Permission Manager"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  show              Show current preferences"
    echo "  reset             Reset all preferences (re-enable dialogs)"
    echo "  allow-files       Always allow file modifications"
    echo "  ask-files         Ask for file modification permissions"
    echo "  help              Show this help message"
}

show_preferences() {
    echo "Current Claude Code Permissions:"
    echo "================================"
    
    if [ ! -f "$PREFERENCES_FILE" ]; then
        echo "No preferences set (all dialogs enabled)"
        return
    fi
    
    if grep -q "file_modifications=always_allow" "$PREFERENCES_FILE" 2>/dev/null; then
        echo "File modifications: ALWAYS ALLOW (no dialogs)"
    else
        echo "File modifications: ASK (dialogs enabled)"
    fi
}

reset_preferences() {
    if [ -f "$PREFERENCES_FILE" ]; then
        rm "$PREFERENCES_FILE"
        echo "All preferences reset. Dialogs re-enabled."
        notify-send -i dialog-information "Claude Permissions Reset" "All dialogs re-enabled" -t 2000
    else
        echo "No preferences to reset."
    fi
}

set_file_preference() {
    mkdir -p "$(dirname "$PREFERENCES_FILE")"
    
    case "$1" in
        "always_allow")
            # Remove any existing file_modifications line and add new one
            grep -v "file_modifications=" "$PREFERENCES_FILE" 2>/dev/null > "${PREFERENCES_FILE}.tmp" || true
            echo "file_modifications=always_allow" >> "${PREFERENCES_FILE}.tmp"
            mv "${PREFERENCES_FILE}.tmp" "$PREFERENCES_FILE"
            echo "File modifications will now be automatically allowed."
            notify-send -i dialog-information "Auto-approval Enabled" "File modifications automatically allowed" -t 2000
            ;;
        "ask")
            # Remove file_modifications line
            grep -v "file_modifications=" "$PREFERENCES_FILE" 2>/dev/null > "${PREFERENCES_FILE}.tmp" || true
            mv "${PREFERENCES_FILE}.tmp" "$PREFERENCES_FILE"
            echo "File modification dialogs re-enabled."
            notify-send -i dialog-information "Dialogs Re-enabled" "Will ask for file modification permission" -t 2000
            ;;
    esac
}

case "${1:-show}" in
    "show"|"status")
        show_preferences
        ;;
    "reset"|"clear")
        reset_preferences
        ;;
    "allow-files")
        set_file_preference "always_allow"
        ;;
    "ask-files")
        set_file_preference "ask"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information."
        exit 1
        ;;
esac