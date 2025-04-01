#!/bin/bash

set -e

main() {
    local -r session_name='main'
    local window=''

    tmux new-session -d -s "${session_name}"

    window='0'
    tmux rename-window -t ${session_name}:${window} 'programs'

    window='1'
    tmux new-window -t ${session_name}:${window} -n 'maintenance'

    # TODO
    # [#27] source project window names from a dotfile configuration of user.
    window='2'
    tmux new-window -t ${session_name}:${window} -n 'rogue-forever'

    window='3'
    tmux new-window -t ${session_name}:${window} -n 'poet'

    window='4'
    tmux new-window -t ${session_name}:${window} -n 'c-encapsulation'

    window='5'
    tmux new-window -t ${session_name}:${window} -n 'c-logging'

    tmux select-window -t ${session_name}:1

    tmux attach-session -t ${session_name}
}

main "${@}"
