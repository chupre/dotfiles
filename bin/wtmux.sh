#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$SCRIPT_DIR:$PATH"

TMUX_BIN="${TMUX_BIN:-tmux}"
FZF_BIN="${FZF_BIN:-fzf}"
RESURRECT_SAVE="${RESURRECT_SAVE:-$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh}"
RESURRECT_RESTORE="${RESURRECT_RESTORE:-$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh}"
RESURRECT_DIR="${RESURRECT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect}"
RESTORE_SESSION="__wtmux_restore__"

warn_missing_persistence() {
    if [[ ! -x "$RESURRECT_SAVE" ]] || [[ ! -x "$RESURRECT_RESTORE" ]]; then
        printf 'Warning: tmux-resurrect is not installed under ~/.tmux/plugins.\n' >&2
        printf 'Install TPM plugins with prefix + I; persistence is currently disabled.\n' >&2
    fi
}

restore_saved_environment() {
    local sessions="$1"
    local last_save="$RESURRECT_DIR/last"

    [[ -n "$sessions" ]] && return
    [[ -f "$last_save" ]] || return
    [[ -x "$RESURRECT_RESTORE" ]] || return

    printf 'Restoring saved tmux environment...\n'
    "$TMUX_BIN" new-session -d -s "$RESTORE_SESSION" -c "$HOME" || return
    "$TMUX_BIN" set-option -g @resurrect-dir "$RESURRECT_DIR"

    local tmux_env
    tmux_env=$("$TMUX_BIN" display-message -p '#{socket_path},#{pid},0')
    if [[ -z "$tmux_env" ]]; then
        printf 'Warning: could not resolve the tmux server socket.\n' >&2
        "$TMUX_BIN" kill-session -t "$RESTORE_SESSION" 2>/dev/null
        return
    fi

    local restore_output
    if ! restore_output=$(TMUX="$tmux_env" "$RESURRECT_RESTORE" 2>&1); then
        printf 'Warning: tmux-resurrect restore failed.\n' >&2
        [[ -n "$restore_output" ]] && printf '%s\n' "$restore_output" >&2
        "$TMUX_BIN" kill-session -t "$RESTORE_SESSION" 2>/dev/null
        return
    fi

    # Resurrect normally replaces the single bootstrap pane. Remove it if a
    # plugin/version leaves it behind alongside restored sessions.
    if "$TMUX_BIN" has-session -t "$RESTORE_SESSION" 2>/dev/null; then
        local session_count
        session_count=$("$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null | wc -l)
        if (( session_count > 1 )); then
            "$TMUX_BIN" kill-session -t "$RESTORE_SESSION"
        else
            printf 'Warning: snapshot did not restore any tmux sessions.\n' >&2
            [[ -n "$restore_output" ]] && printf '%s\n' "$restore_output" >&2
            "$TMUX_BIN" kill-session -t "$RESTORE_SESSION"
        fi
    fi
}

warn_missing_persistence

while true; do
    # Get existing session names
    sessions=$("$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null)

    restore_saved_environment "$sessions"
    sessions=$("$TMUX_BIN" list-sessions -F '#{session_name}' 2>/dev/null)

    # Add extra options
    extra_options="➕  Create new session"$'\n'"❌  Kill a session"
    menu=$(printf "%s\n" "$sessions" "$extra_options")

    # Show fzf menu
    choice=$(printf "%s\n" "$menu" | "$FZF_BIN" --prompt="Select session: ")
    [[ -z "$choice" ]] && exit 0

    case "$choice" in
        "➕  Create new session")
            read -rp "Enter new session name: " newname
            [[ -z "$newname" ]] && continue
            "$TMUX_BIN" new-session -s "$newname"
            ;;
        "❌  Kill a session")
            if [[ -z "$sessions" ]]; then
                echo "No sessions to kill."
                sleep 1
                continue
            fi
            # Pick which session to kill
            kill_choice=$(printf "%s\n" "$sessions" | "$FZF_BIN" --prompt="Select session to kill: ")
            if [[ -n "$kill_choice" ]]; then
                "$TMUX_BIN" kill-session -t "$kill_choice"

                # Update the snapshot only while another session keeps the
                # tmux server alive.
                if "$TMUX_BIN" list-sessions >/dev/null 2>&1 && [[ -x "$RESURRECT_SAVE" ]]; then
                    "$RESURRECT_SAVE"
                fi
                echo "Session '$kill_choice' killed."
                sleep 1
            fi
            ;;
        *)
            exec "$TMUX_BIN" attach-session -t "$choice"
            ;;
    esac
done
