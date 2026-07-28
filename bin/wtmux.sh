#!/usr/bin/env bash

# Path to tmux-resurrect save/restore scripts
RESURRECT_SAVE="$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh"
RESURRECT_RESTORE="$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh"
RESURRECT_DIR="$HOME/.local/share/tmux/resurrect"

while true; do
    # Get existing session names
    sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

    # Auto-restore if we have saved sessions but no running sessions
    if [[ -z "$sessions" ]] && [[ -d "$RESURRECT_DIR" ]]; then
        # Check if there's a last save file
        last_save="$RESURRECT_DIR/last"
        [[ ! -e "$last_save" ]] && last_save=$(ls -t "$RESURRECT_DIR"/tmux_resurrect_*.txt 2>/dev/null | head -1)
        
        if [[ -f "$last_save" ]]; then
            echo "Restoring saved sessions..."
            # Extract unique session names with their first working directory
            declare -A session_dirs
            while IFS=$'\t' read -r type session_name window_idx pane_idx flags active work_dir full_path rest; do
                if [[ "$type" == "pane" ]] && [[ -n "$session_name" ]] && [[ ! -v session_dirs[$session_name] ]]; then
                    # Remove leading colon from path
                    work_path="${full_path#:}"
                    session_dirs[$session_name]="$work_path"
                fi
            done < "$last_save"
            
            # Create sessions
            for session_name in "${!session_dirs[@]}"; do
                work_path="${session_dirs[$session_name]}"
                if ! tmux has-session -t "$session_name" 2>/dev/null; then
                    tmux new-session -d -s "$session_name" -c "$work_path" 2>/dev/null
                    echo "Created session: $session_name"
                fi
            done
            sleep 1
            # Refresh sessions list after restore
            sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
        fi
    fi

    # Add extra options
    extra_options="➕  Create new session"$'\n'"❌  Kill a session"
    menu=$(printf "%s\n" "$sessions" "$extra_options")

    # Show fzf menu
    choice=$(printf "%s\n" "$menu" | fzf --prompt="Select session: ")

    case "$choice" in
        "➕  Create new session")
            read -rp "Enter new session name: " newname
            [[ -z "$newname" ]] && continue
            tmux new-session -s "$newname"
            ;;
        "❌  Kill a session")
            if [[ -z "$sessions" ]]; then
                echo "No sessions to kill."
                sleep 1
                continue
            fi
            # Pick which session to kill
            kill_choice=$(printf "%s\n" "$sessions" | fzf --prompt="Select session to kill: ")
            if [[ -n "$kill_choice" ]]; then
                tmux kill-session -t "$kill_choice"
                # Update tmux-resurrect snapshot so it won't resurrect this session
                "$RESURRECT_SAVE"
                echo "Session '$kill_choice' killed."
                sleep 1
            fi
            ;;
        *)
            exec tmux attach-session -t "$choice"
            ;;
    esac
done

