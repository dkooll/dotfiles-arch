# Path and environment
export PATH="$HOME/.local/bin:$PATH"
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# fnm (Node.js version manager)
export FNM_DIR="$HOME/.local/share/fnm"
[[ -d "$FNM_DIR" ]] && export PATH="$FNM_DIR:$PATH" && eval "$(fnm env --use-on-cd)"
export GREP_OPTIONS="--color=never"
export TF_CLI_ARGS="-no-color"
export EZA_COLORS="di=38;5;109:fi=38;5;132:*.*=38;5;132:Makefile=38;5;132:README=38;5;132:Dockerfile=38;5;132:da=none:un=38;5;109:gu=38;5;109:uu=38;5;109:ur=38;5;187:uw=38;5;187:ux=38;5;187:gr=38;5;187:gw=38;5;187:gx=38;5;187:tr=38;5;187:tw=38;5;175:tx=38;5;187:sn=none:sb=none:hd=none:lp=none:cc=none:mi=none:pi=none:so=none:bd=none:cd=none:or=none:su=none:sf=none:ow=38;5;187:st=38;5;187"
export TERM=xterm-256color

# History
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000
export SAVEHIST=1000

# ZSH options
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_FIND_NO_DUPS HIST_IGNORE_SPACE HIST_VERIFY EXTENDED_HISTORY

# Enable completion system
autoload -Uz compinit
compinit

# FZF setup
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix --exclude .git"

# FZF completion functions
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}
_fzf_compgen_dir() {
  fd --type d --hidden --exclude .git . "$1"
}

# Alias definitions
alias tf='terraform'
alias t='tmux'
alias ls='eza --color=auto --icons'
alias ll='eza -la --color=auto --icons'
alias lt='eza --tree --color=auto --icons'
alias lh='eza -ld .* --color=auto --icons'
alias lg='eza -l --git --color=auto --icons'
alias l='eza --color=auto'
alias lrs='eza --tree --long --level=2 --color=auto --icons'
