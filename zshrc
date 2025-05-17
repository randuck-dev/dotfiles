HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
unsetopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
unsetopt HIST_IGNORE_ALL_DUPS
unsetopt HIST_SAVE_NO_DUPS
unsetopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY
unsetopt autocd

export ASPNETCORE_ENVIRONMENT="Development"
export DOTNET_ROOT="/nix/store/fq92my07v728cgnlvcq9q1wb43i20v4s-dotnet-wrapped-combined/share/dotnet"
export DOTNET_HOST_PATH="/nix/store/fq92my07v728cgnlvcq9q1wb43i20v4s-dotnet-wrapped-combined/dotnet"

alias ls='ls --color=auto'

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/.dotnet/tools
export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin

export PATH=$PATH:$HOME/bin

export PATH=$PATH:/opt/nvim-linux64/bin

export PATH=/opt/homebrew/opt/python@3.12/libexec/bin:$PATH

alias bs="bash $HOME/.dotfiles/dev.sh"
alias dots="cd $HOME/.dotfiles"


