export TMUXDIR="$XDG_CONFIG_HOME/tmux"

export VISUAL="nvim"
export EDITOR="$VISUAL"
export MANPAGER="nvim +Man!"

typeset -gU path PATH
path=(
    "/etc/profiles/per-user/bruno/bin"
    "$HOME/.local/bin"
    "$HOME/.nix-profile/bin"
    $path
)

if [[ "$OSTYPE" == darwin* ]]; then
    export DOCKER_HOST="unix:///tmp/podman/podman-machine-default-api.sock"
    export PI_CODING_AGENT_DIR="$HOME/.config/pi/agent"

    path=(
        "$HOME/.lmstudio/bin"
        $path
    )
fi
