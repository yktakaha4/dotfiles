#!/bin/bash

set -euo pipefail

tmux_pane_id="$TMUX_PANE"
timeout=3
send_key_delay=1

if [ -z "$tmux_pane_id" ]; then
    exit 0
fi

initial_activity="$(tmux display-message -p -t "$tmux_pane_id" '#{pane_activity}')"

sleep $timeout

current_activity="$(tmux display-message -p -t "$tmux_pane_id" '#{pane_activity}')"
if [ "$initial_activity" != "$current_activity" ]; then
    exit 0
fi

tmux send-keys -t $tmux_pane_id Escape
sleep $send_key_delay

tmux send-keys -t $tmux_pane_id "ユーザーが一定時間操作を行わなかったため、自動的にキャンセルされました。提案した作業は実施できないものとして作業を継続してください。"
sleep $send_key_delay

tmux send-keys -t $tmux_pane_id Enter
