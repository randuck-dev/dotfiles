{ config, pkgs, lib, ...}:
let user = config.username;
in
{
  home-manager.users.${user}.programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    autocd = false;

    initExtraFirst = ''
    '';
    initExtra = ''
# ---- CUSTOM CODE ----
alias ls='ls --color=auto'

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/.dotnet/tools
export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin

# custom binaries
export PATH=$PATH:$HOME/bin

export PATH=$PATH:/opt/nvim-linux64/bin

export PATH=/opt/homebrew/opt/python@3.12/libexec/bin:$PATH

alias bs="bash $HOME/.dotfiles/dev.sh"
alias dots="cd $HOME/.dotfiles"

eval "$(direnv hook zsh)"

# ---- END CUSTOM CODE ----
    '';
  };
}
