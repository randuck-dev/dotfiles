{ config, pkgs, ... }:
let user = config.username;
in
{
  home-manager.users.${user}.programs.tmux = {
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
}
