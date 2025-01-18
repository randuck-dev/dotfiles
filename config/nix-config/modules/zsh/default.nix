{ config, pkgs, lib, ...}:
let user = config.username;
in
{

  home-manager.users.${user}.programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    autocd = false;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    initExtraFirst = ''
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
fi

# Always color ls and group directories
alias ls='ls --color=auto'

# export ZSH="$HOME/.oh-my-zsh"

#source $ZSH/oh-my-zsh.sh

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/.dotnet/tools
export PATH=/opt/homebrew/bin:$PATH
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin

# custom binaries
export PATH=$PATH:$HOME/bin

export PATH=$PATH:/opt/nvim-linux64/bin

alias bs="bash $HOME/.dotfiles/dev.sh"
alias dots="cd $HOME/.dotfiles"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(direnv hook zsh)"
    '';
  };
}
