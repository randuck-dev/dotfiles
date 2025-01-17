{ user, name, email, config, pkgs, lib, home-manager, ... }:

let 
    additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    masApps = {
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        stateVersion = "23.11";
      };
      programs = {
        zsh = {
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

        git = {
          enable = true;
          ignores = [ "*.swp" ];
          userName = name;
          userEmail = email;
          lfs = {
            enable = true;
          };
          extraConfig = {
            init.defaultBranch = "main";
            core = {
            editor = "vim";
              autocrlf = "input";
            };
            pull.rebase = true;
            rebase.autoStash = true;
          };
        };

        vim = {
          enable = true;
          plugins = with pkgs.vimPlugins; [ vim-airline vim-airline-themes vim-startify vim-tmux-navigator ];
          settings = { ignorecase = true; };
          extraConfig = ''
            '';
          };

        ssh = {
          enable = true;
          includes = [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
              "/home/${user}/.ssh/config_external"
            )
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
              "/Users/${user}/.ssh/config_external"
            )
          ];
          matchBlocks = {
            "github.com" = {
              identitiesOnly = true;
              identityFile = [
                (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
                  "/home/${user}/.ssh/id_github"
                )
                (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
                  "/Users/${user}/.ssh/id_github"
                )
              ];
            };
          };
        };

        tmux = {
          enable = true;
          plugins = with pkgs.tmuxPlugins; [
            vim-tmux-navigator
            sensible
            yank
            prefix-highlight
            {
              plugin = power-theme;
              extraConfig = ''
                set -g @tmux_power_theme 'gold'
              '';
            }
            {
              plugin = resurrect; # Used by tmux-continuum

              # Use XDG data directory
              # https://github.com/tmux-plugins/tmux-resurrect/issues/348
              extraConfig = ''
                set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
                set -g @resurrect-capture-pane-contents 'on'
                set -g @resurrect-pane-contents-area 'visible'
              '';
            }
            {
              plugin = continuum;
              extraConfig = ''
                set -g @continuum-restore 'on'
                set -g @continuum-save-interval '5' # minutes
              '';
            }
          ];
          terminal = "screen-256color";
          prefix = "C-f";
          shell = "/bin/zsh";
          escapeTime = 10;
          historyLimit = 50000;
          extraConfig = ''
            bind-key r source-file ~/.tmux.conf \; display "Reloaded!"

            set -g mouse on
            set -g default-command "$SHELL"

            bind-key v split-window -h -c "#{pane_current_path}"
            bind-key h split-window -v -c "#{pane_current_path}"

            bind -n C-h previous-window
            bind -n C-l next-window


            bind-key g send-keys "source ~/.dotfiles/run.sh" Enter
            bind-key -r f run-shell "tmux neww ~/.dotfiles/tmux-sessionizer.sh"

            bind-key "C-k" run-shell "sesh connect \"$(
              sesh list --icons | fzf-tmux -p 55%,60% \
                --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
                --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
                --bind 'tab:down,btab:up' \
                --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
                --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
                --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
                --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
                --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
                --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            )\""


            # theme
            set-window-option -g window-status-current-style bold,bg=colour1,fg=colour234
            set-window-option -g window-status-style fg=colour35
            set -g window-status-activity-style bold,bg=colour234,fg=white
            set-option -g message-style bg=colour237,fg=colour231
            set-option -g pane-border-style fg=colour36
            set-option -g pane-active-border-style fg=colour35

            # Status Bar
            set -g status-justify centre
            set -g status-bg black
            set -g status-fg colour35
            set -g status-interval 60
            set -g status-left-length 50
            set -g status-left "#[bg=colour105]💻#[fg=colour234,bold] #H#[bg=colour34]#[bg=colour105,nobold]#[fg=colour234] [#S] $tmux_target_lower"
            set -g status-right '#[bg=colour105] 🕔 #[fg=colour234,bold]%H:%M '


            set -g default-terminal "xterm-256color"
            set -g terminal-features "xterm-256color:RGB"
            '';
          };
        };
      manual.manpages.enable = false;
    };
  };

  local.dock.enable = true;
  local.dock.entries = [
    { path = "/Applications/Ghostty.app/"; }
    { path = "/Applications/Rider.app/"; }
    { path = "/Applications/Microsoft Edge.app/"; }
    { path = "/Applications/Visual Studio Code.app/"; }
    { path = "/Applications/Notion.app/"; }
  ];
}
