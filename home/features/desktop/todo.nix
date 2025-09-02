{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.todo;

  # Todo management script using wofi
  wofi-todo = pkgs.writeShellScriptBin "wofi-todo" ''
    # Prevent multiple instances
    LOCK_FILE="/tmp/wofi-todo.lock"
    if [[ -f "$LOCK_FILE" ]]; then
      exit 0
    fi
    trap "rm -f $LOCK_FILE" EXIT
    touch "$LOCK_FILE"

    TODO_FILE="$HOME/.local/share/todos.txt"
    WOFI_HEIGHT="400"
    WOFI_WIDTH="600"
    mkdir -p "$(dirname "$TODO_FILE")"
    touch "$TODO_FILE"

    # Function to display todos with numbers
    show_todos() {
      if [[ -s "$TODO_FILE" ]]; then
        cat -n "$TODO_FILE"
      else
        echo "No todos yet!"
      fi
    }

    # Function to add a new todo
    add_todo() {
      local new_todo="$1"
      if [[ -n "$new_todo" ]]; then
        echo "$new_todo" >> "$TODO_FILE"
        notify-send "Todo Added" "$new_todo" -t 2000
      fi
    }

    # Function to remove a todo by line number
    remove_todo() {
      local line_num="$1"
      if [[ "$line_num" =~ ^[0-9]+$ ]] && [[ "$line_num" -gt 0 ]]; then
        local todo_text=$(sed -n "''${line_num}p" "$TODO_FILE")
        if [[ -n "$todo_text" ]]; then
          sed -i "''${line_num}d" "$TODO_FILE"
          notify-send "Todo Completed" "$todo_text" -t 2000
        fi
      fi
    }

    # Main menu options
    MENU_OPTIONS="📝 Add Todo
📋 View Todos
✅ Complete Todo
🗑️ Clear All"

    # Show main menu
    choice=$(echo "$MENU_OPTIONS" | wofi --dmenu --prompt "Todo Manager" --lines 4 --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT")

    case "$choice" in
      "📝 Add Todo")
        new_todo=$(echo "" | wofi --dmenu --prompt "New Todo:" --lines 1 --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT")
        if [[ -n "$new_todo" ]]; then
          add_todo "$new_todo"
        fi
        ;;
      "📋 View Todos")
        todos=$(show_todos)
        if [[ "$todos" != "No todos yet!" ]]; then
          echo "$todos" | wofi --dmenu --prompt "Your Todos" --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT"
        else
          notify-send "Todo List" "No todos yet!" -t 2000
        fi
        ;;
      "✅ Complete Todo")
        if [[ -s "$TODO_FILE" ]]; then
          todos=$(show_todos)
          selected=$(echo "$todos" | wofi --dmenu --prompt "Complete which todo?" --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT")
          if [[ -n "$selected" ]]; then
            line_num=$(echo "$selected" | awk '{print $1}')
            remove_todo "$line_num"
          fi
        else
          notify-send "Todo List" "No todos to complete!" -t 2000
        fi
        ;;
      "🗑️ Clear All")
        if [[ -s "$TODO_FILE" ]]; then
          confirm=$(echo -e "Yes\nNo" | wofi --dmenu --prompt "Clear all todos?" --lines 2 --width "$WOFI_WIDTH" --height "$WOFI_HEIGHT")
          if [[ "$confirm" == "Yes" ]]; then
            > "$TODO_FILE"
            notify-send "Todo List" "All todos cleared!" -t 2000
          fi
        else
          notify-send "Todo List" "No todos to clear!" -t 2000
        fi
        ;;
    esac
  '';
in {
  options.features.desktop.todo.enable =
    mkEnableOption "todo manager with wofi integration";

  config = mkIf cfg.enable {
    # Install todo script and required dependencies
    home.packages = with pkgs; [
      wofi-todo
      libnotify # for notifications
    ];

    # Hyprland keybind for todo manager
    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mainMod, N, exec, wofi-todo"
      ];
    };
  };
}