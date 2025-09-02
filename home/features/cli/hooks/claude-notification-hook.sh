#!/usr/bin/env bash

# Post-operation notification hook for Claude Code
# Sends desktop notifications after successful file operations

# Read input from stdin
input=$(cat)

# Parse the hook event details
hook_event_name=$(echo "$input" | @jq@ -r '.hook_event_name')
tool_name=$(echo "$input" | @jq@ -r '.tool_name // empty')
tool_input=$(echo "$input" | @jq@ '.tool_input // empty')
tool_output=$(echo "$input" | @jq@ '.tool_output // empty')

# Only process PostToolUse events
if [ "$hook_event_name" = "PostToolUse" ]; then
    # Notify about successful file operations
    if [[ "$tool_name" == "Write" || "$tool_name" == "Edit" || "$tool_name" == "MultiEdit" ]]; then
        file_path=$(echo "$tool_input" | @jq@ -r '.file_path // empty')
        
        if [[ -n "$file_path" ]]; then
            file_name="${file_path##*/}"
            
            case "$tool_name" in
                "Write")
                    @notifysend@ -i document-save "📄 File Written" "$file_name" -t 10000
                    ;;
                "Edit")
                    @notifysend@ -i document-edit "✏️ File Edited" "$file_name" -t 10000
                    ;;
                "MultiEdit")
                    @notifysend@ -i document-edit "🔧 Multi-Edit Complete" "$file_name" -t 10000
                    ;;
            esac
        fi
    fi
    
    # Notify about successful bash command completion (for important commands only)
    if [[ "$tool_name" == "Bash" ]]; then
        command=$(echo "$tool_input" | @jq@ -r '.command // empty')
        
        # Only notify for long running commands
        if [[ ${#command} -gt 80 ]]; then
            @notifysend@ -i utilities-terminal "✅ Command Complete" \
                       "${command:0:50}..." -t 10000
        fi
    fi
fi

# Always return success for post-operation hooks
echo '{
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse"
    }
}'