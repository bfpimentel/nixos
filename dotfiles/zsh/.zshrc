HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

for file in "$ZDOTDIR"/conf.d/*.zsh(N); do
    source "$file"
done

_zsh_cache_dir="$HOME/.cache/zsh"
[[ -d "$_zsh_cache_dir" ]] || mkdir -p -- "$_zsh_cache_dir"

zsh_plugins_txt="$ZDOTDIR/.zsh_plugins.txt"
zsh_plugins_bundle="$_zsh_cache_dir/plugins.zsh"
antidote_zsh=""

for profile in "$HOME/.local" "$HOME/.nix-profile" "/etc/profiles/per-user/$USER" "/run/current-system/sw"; do
    if [[ -r "$profile/share/antidote/antidote.zsh" ]]; then
        antidote_zsh="$profile/share/antidote/antidote.zsh"
        break
    fi
done

if [[ -n "$antidote_zsh" ]]; then
    source "$antidote_zsh"
else
    print -u2 "zsh: antidote.zsh not found in Nix profiles"
fi

if [[ -n "$antidote_zsh" && -r "$zsh_plugins_txt" ]]; then
    if [[ ! -r "$zsh_plugins_bundle" || "$zsh_plugins_txt" -nt "$zsh_plugins_bundle" ]]; then
        zsh_plugins_tmp="${zsh_plugins_bundle}.$$"
        if antidote bundle < "$zsh_plugins_txt" >| "$zsh_plugins_tmp"; then
            mv -f -- "$zsh_plugins_tmp" "$zsh_plugins_bundle"
        else
            rm -f -- "$zsh_plugins_tmp"
            print -u2 "zsh: failed to build Antidote plugin bundle"
        fi
    fi

    # zsh-completions must extend fpath before compinit scans it.
    zsh_completions="$(antidote path zsh-users/zsh-completions 2>/dev/null)"
    if [[ -r "$zsh_completions/zsh-completions.plugin.zsh" ]]; then
        typeset -gU fpath FPATH
        source "$zsh_completions/zsh-completions.plugin.zsh"
    fi
fi

autoload -Uz compinit
zmodload zsh/complist
compinit -d "$_zsh_cache_dir/.zcompdump-$ZSH_VERSION"

zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{#928374}%d%f'
zstyle ':completion:*:messages' format '%F{#928374}%d%f'
zstyle ':completion:*:warnings' format '%F{#ea6962}no matches found%f'
zstyle ':fzf-tab:*' switch-group '<' '>'

bindkey '^[[Z' reverse-menu-complete

fzf_share="$(command fzf-share 2>/dev/null)"
if [[ -t 0 && -t 1 && -r "$fzf_share/key-bindings.zsh" ]]; then
    source "$fzf_share/key-bindings.zsh"
elif ! command -v fzf >/dev/null; then
    print -u2 "zsh: fzf not found in PATH"
elif [[ -t 0 && -t 1 ]]; then
    print -u2 "zsh: fzf key bindings not found"
fi

[[ -t 0 && -t 1 && -r "$zsh_plugins_bundle" ]] && source "$zsh_plugins_bundle"

oh_my_posh_bin="$(command -v oh-my-posh)"
if [[ -n "$oh_my_posh_bin" && -t 0 && -t 1 ]]; then
    eval "$("$oh_my_posh_bin" init zsh --config "$ZDOTDIR/bfmp.toml")"
elif [[ -z "$oh_my_posh_bin" ]]; then
    print -u2 "zsh: oh-my-posh not found in PATH"
fi

if command -v direnv >/dev/null; then
    eval "$(command direnv hook zsh)"
fi

unset antidote_zsh fzf_share oh_my_posh_bin profile zsh_completions
unset zsh_plugins_bundle zsh_plugins_tmp zsh_plugins_txt
