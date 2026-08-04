alias gst='lazygit'
alias visudo='sudo -E visudo'

alias cc='cd ~/.dotfiles'
alias ec='cd ~/.dotfiles && nvim .'

alias hm='nh home switch ~/.dotfiles'

if [[ "$OSTYPE" == darwin* ]]; then
    alias os='nh darwin switch ~/.dotfiles'
else
    alias os='nh os switch ~/.dotfiles'
fi
