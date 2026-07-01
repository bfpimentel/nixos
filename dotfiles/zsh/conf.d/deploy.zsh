function deploy() {
    local repo="${DOTFILES:-$HOME/.dotfiles}"
    command python3 "$repo/dotfiles/zsh/conf.d/deploy.py" "$@"
}
