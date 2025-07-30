#!/usr/bin/env bash

# Interactive permission hook using notify-send and zenity
# This hook will show desktop notifications and interactive dialogs for important operations only

# Set up Claude icon and preferences file
CLAUDE_ICON="$HOME/.local/share/icons/claude-code.png"
PREFERENCES_FILE="$HOME/.claude/permission-preferences"

if [ -f "$CLAUDE_ICON" ]; then
    ICON_ARG="--window-icon=$CLAUDE_ICON"
else
    ICON_ARG="--window-icon=applications-development"
fi

# Create preferences directory if it doesn't exist  
mkdir -p "$(dirname "$PREFERENCES_FILE")"

# Read input from stdin
input=$(cat)

# Parse the hook event name and tool details
hook_event_name=$(echo "$input" | @jq@ -r '.hook_event_name')
tool_name=$(echo "$input" | @jq@ -r '.tool_name // empty')
tool_input=$(echo "$input" | @jq@ '.tool_input // empty')

# Only process PreToolUse events
if [ "$hook_event_name" = "PreToolUse" ]; then
    # Interactive prompts for sensitive operations
    if [[ "$tool_name" == "Write" || "$tool_name" == "Edit" || "$tool_name" == "MultiEdit" ]]; then
        file_path=$(echo "$tool_input" | @jq@ -r '.file_path // empty')
        
        # Check if user has set "always allow" for file modifications
        if grep -q "file_modifications=always_allow" "$PREFERENCES_FILE" 2>/dev/null; then
            permission="allow"
            @notifysend@ -i dialog-information "File Modified (Auto-approved)" "${file_path##*/}" -t 1500
        elif command -v @zenity@ &> /dev/null; then
            # Show interactive dialog with three options
            result=$(@zenity@ --question --title="🤖 Claude Code Permission" \
                           --text="Claude wants to modify file:\n$file_path\n\nAllow this operation?" \
                           --width=400 \
                           --extra-button="Allow (don't ask again)" \
                           --ok-label="Allow" \
                           --cancel-label="Deny" \
                           $ICON_ARG 2>&1)
            
            exit_code=$?
            
            # Check if extra button was clicked by examining the result text
            if [[ "$result" == *"Allow (don't ask again)"* ]]; then
                # "Allow (don't ask again)" button clicked
                permission="allow"
                echo "file_modifications=always_allow" >> "$PREFERENCES_FILE"
                @notifysend@ -i dialog-information "Auto-approval Enabled" "Future file modifications will be automatically allowed" -t 3000
            elif [ "$exit_code" -eq 0 ]; then
                # Allow button clicked
                permission="allow"
                @notifysend@ -i dialog-information "File Modified" "${file_path##*/}" -t 2000
            else
                # Deny button clicked or dialog canceled
                permission="deny"
                @notifysend@ -i dialog-warning "Operation Denied" "File modification blocked" -t 2000
            fi
        else
            # For now, use "ask" to trigger Claude's built-in prompt  
            permission="ask"
        fi
        
        echo "{
            \"hookSpecificOutput\": {
                \"hookEventName\": \"PreToolUse\",
                \"permissionDecision\": \"$permission\",
                \"permissionDecisionReason\": \"File modification requires user confirmation\"
            }
        }"
        exit 0
    fi
    
    # Notify and ask for dangerous bash commands
    if [[ "$tool_name" == "Bash" ]]; then
        command=$(echo "$tool_input" | @jq@ -r '.command // empty')
        
        # Check for potentially dangerous commands
        if [[ "$command" == *"rm -rf"* ]] || \
           [[ "$command" == *"dd if="* ]] || \
           [[ "$command" == *"mkfs"* ]] || \
           [[ "$command" == *"> /dev/"* ]] || \
           [[ "$command" == *"sudo"* ]]; then
            
            @notifysend@ -u critical -i dialog-error "⚠️ Dangerous Command" \
                       "${command:0:50}..." -t 0
            
            echo '{
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "ask",
                    "permissionDecisionReason": "Potentially dangerous command detected"
                }
            }'
            exit 0
        fi
        
        # Don't notify for simple/common commands
        # Only notify for complex or important bash commands
        if [[ ${#command} -gt 80 ]] || \
           [[ "$command" == *"git"* ]] || \
           [[ "$command" == *"npm"* ]] || \
           [[ "$command" == *"cargo"* ]] || \
           [[ "$command" == *"nix"* ]]; then
            # Brief notification for important commands
            @notifysend@ -i utilities-terminal "🚀 Running" \
                       "${command:0:60}..." -t 1500
        fi
    fi
    
    # Only notify about external web operations
    if [[ "$tool_name" == "WebFetch" ]]; then
        url=$(echo "$tool_input" | @jq@ -r '.url // "N/A"')
        # Only notify for external URLs (not localhost/internal)
        if [[ ! "$url" == *"localhost"* ]] && [[ ! "$url" == *"127.0.0.1"* ]]; then
            @notifysend@ -i web-browser "🌐 Web Access" \
                       "${url:0:50}..." -t 2000
        fi
    fi
fi

# Allow all other operations by default
echo '{
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow"
    }
}'