# AGENTS.md

This file provides guidance to AI coding agents (Claude Code and others) when working in this repository.

## Purpose

Baseline dotfiles and machine setup shared by all of the user's machines: macOS (Homebrew + symlinks, including a work machine) and a NixOS desktop (Hyprland). The repo is **public** and must live at `~/.dotfiles`, because scripts, tmux bindings and `zshrc` hardcode that path.

## Public repo: keep machine-specific data out

- Nothing that identifies the user's employer or work setup goes in the repo. Machine-specific values are asked for during setup and stored outside the repo (see `git-identity.sh`).
- No secrets, tokens or credentials. Credentials live outside the repo (e.g. the CIFS mount reads `/root/.smbcredentials`).

## Setup

`./dev.sh` sets up any machine and is safe to re-run (the `bs` alias in `zshrc` runs it):
1. `config.sh` symlinks each `config/<name>` directory to `~/.config/<name>`, skipping targets that already exist.
2. `git-identity.sh` asks once (only when interactive) which GitHub owners need a different git email. It writes `~/.gitconfig.local` (with `includeIf "hasconfig:remote.*.url:..."` rules) and `~/.gitconfig.<owner>`. `config/git/config` includes `~/.gitconfig.local` last. Delete `~/.gitconfig.local` to be asked again.
3. `oh-my-zsh.sh` installs oh-my-zsh and the plugins `zshrc` uses.
4. Symlinks `zshrc` and `.ideavimrc` into `~` if they don't exist.
5. On macOS, applies the flake's `mac` config with `sudo darwin-rebuild switch --flake ~/.dotfiles#mac` (the first run uses the flake's own `darwin-rebuild` package). Needs Homebrew and Nix installed first. On NixOS it only prints a reminder to run `athena-update`.

## Nix flake

- `nix/common.nix`: packages and fonts for **every** machine. A tool wanted everywhere goes here.
- `nix/darwin.nix`: macOS-only (nix-darwin). One config, `darwinConfigurations.mac`, for all Macs; nothing machine-specific. Desktop apps are Homebrew casks (`homebrew.casks`); activation never removes other Homebrew packages (`cleanup = "none"`). `nix.enable = false` because Nix itself is Lix, managed by its installer, which also doesn't turn on flakes by default, so pass `--extra-experimental-features "nix-command flakes"` to `nix` commands.
- `nix/configuration.nix` (+ `hardware-configuration.nix`): the NixOS desktop, `nixosConfigurations.nixos`. Apply with `sudo nixos-rebuild switch --flake ~/.dotfiles/#nixos` (wrapped by `bin/athena-update`).
- Inputs: `nixos-26.05` for NixOS, `nixpkgs-26.05-darwin` for macOS, `nix-darwin-26.05`, and `nixos-unstable` passed to modules as `pkgs-unstable`. Custom packages live in `nix/tools/` (`pkgs.callPackage`).
- Check locally: `nix build .#darwinConfigurations.mac.system` on a Mac. Evaluating the NixOS config needs an x86_64-linux builder (part of it is built during evaluation), so on a Mac rely on CI for that.
- New files must be `git add`ed before the flake sees them.

CI (`.github/workflows/flake.yml`) runs on pushes and PRs to `main`: it builds the macOS config on `macos-15` and evaluates the NixOS config on Ubuntu (not a full build: unfree packages like NVIDIA drivers aren't in the binary cache). Anything in `dev.sh` that prompts must skip when stdin isn't a terminal.

## Layout notes

- `config/`: XDG configs symlinked into `~/.config`. `.gitignore` ignores `config/*` and re-includes a whitelist, so **a new `config/<name>` directory also needs a `!config/<name>` line in `.gitignore`** or it won't be committed.
- Hyprland desktop (NixOS): `config/hypr` (main config is `hyprland.lua`), `waybar`, `wofi`, `uwsm`, `brightnessctl-rs`. `zshrc` starts Hyprland through `uwsm` when available. `bin/athena-*` are the helper scripts those configs call; `zshrc` adds `bin/` to `PATH`.
- macOS: `config/aerospace` (tiling WM).
- `config/nvim`: LazyVim. Plugin specs in `lua/plugins/`; custom Lua tools in `plugin/` (`nugetify.lua`, `gh_fetcher.lua`, `fleetingnotes.lua`).

## tmux + worktree workflow

Root-level scripts are bound in `config/tmux/tmux.conf`:
- `tmux-sessionizer.sh` (`prefix f`, `prefix d` for this repo): fzf over `~/projects` and `~/oss-projects`, opens or switches to a session.
- `tmux-worktree-picker.sh` (`prefix W`): fzf over `git worktree list` for the current repo, opens a window named after the branch.
- `tmux-wt-spawn.sh` (`prefix C`): creates a worktree for a branch off the main checkout and opens a window running `claude` in it.
- `tmux-claude-picker.sh` (`prefix A`): lists windows tagged `@claude=1`; windows with `monitor-silence` firing (Claude likely waiting for input) sort first.

`zshrc` also wraps the `wt` command so `wt switch` opens or selects a tmux window named after the branch.

## Version control

Plain git. Parallel work happens in git worktrees (see the tmux scripts above). Remote: `https://github.com/randuck-dev/dotfiles`.
