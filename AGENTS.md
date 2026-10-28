# AGENTS.md

This file provides guidance to AI coding agents (Claude Code and others) when working in this repository.

## Purpose

Baseline dotfiles and machine setup shared by all of the user's machines: macOS (Homebrew + symlinks, including a work machine) and a NixOS desktop (Hyprland). The repo is **public** and must live at `~/.dotfiles`, because scripts, tmux bindings and `zshrc` hardcode that path.

## Public repo: keep machine-specific data out

- Nothing that identifies the user's employer or work setup goes in the repo. Machine-specific values are asked for during setup and stored outside the repo (see `git-identity.sh`).
- No secrets, tokens or credentials. Credentials live outside the repo (e.g. the CIFS mount reads `/root/.smbcredentials`).

## Two setup paths

**macOS bootstrap (`./dev.sh`)** — run from the repo root (it sources `./config.sh` etc. relatively). The `bs` alias in `zshrc` runs it.
1. `config.sh` symlinks each `config/<name>` directory to `~/.config/<name>`, skipping targets that already exist.
2. `git-identity.sh` asks once (only when interactive) which GitHub owners need a different git email. It writes `~/.gitconfig.local` (with `includeIf "hasconfig:remote.*.url:..."` rules) and `~/.gitconfig.<owner>`. `config/git/config` includes `~/.gitconfig.local` last. Delete `~/.gitconfig.local` to be asked again.
3. `brew-deps.sh` (macOS only) runs every script in `pkgs/`; each is a plain `brew install ...`. `grep=<pattern> ./dev.sh` runs only the `pkgs/` scripts whose name matches.
4. Symlinks `zshrc` → `~/.zshrc` and `.ideavimrc` → `~/.ideavimrc` if they don't exist.

CI (`.github/workflows/ci-dev.yml`) runs `./dev.sh` on `macos-14` for pushes and PRs to `main`, non-interactively. Anything in `dev.sh` that prompts must skip when stdin isn't a terminal.

**NixOS flake (`flake.nix`)** — one host, `nixosConfigurations.nixos` (x86_64-linux), built from `nix/configuration.nix` (+ `nix/hardware-configuration.nix`). nixpkgs is `nixos-26.05`; `pkgs-unstable` (nixos-unstable, unfree allowed) is passed as a module argument for packages that need newer versions. Custom packages live in `nix/tools/` and are pulled in with `pkgs.callPackage`.
- Apply: `sudo nixos-rebuild switch --flake ~/.dotfiles/#nixos` (wrapped by `bin/athena-update`, which sends a desktop notification). Check without switching: `nixos-rebuild build --flake .#nixos`.
- New files must be tracked by git before a flake build sees them.

macOS packages come from `pkgs/*.sh`, Linux packages from `nix/configuration.nix`. A tool wanted on both needs both.

## Layout notes

- `config/`: XDG configs symlinked into `~/.config`. `.gitignore` ignores `config/*` and re-includes a whitelist, so **a new `config/<name>` directory also needs a `!config/<name>` line in `.gitignore`** or it won't be committed.
- Hyprland desktop (NixOS): `config/hypr` (main config is `hyprland.lua`), `waybar`, `wofi`, `uwsm`, `brightnessctl-rs`. `zshrc` starts Hyprland through `uwsm` when available. `bin/athena-*` are the helper scripts those configs call; `zshrc` adds `bin/` to `PATH`.
- macOS: `config/aerospace` (tiling WM).
- `config/nvim`: LazyVim. Plugin specs in `lua/plugins/`; custom Lua tools in `plugin/` (`nugetify.lua`, `gh_fetcher.lua`, `fleetingnotes.lua`).
- `config/jj`: Jujutsu config. It sets `user.email` itself, because jj does not read git's config, so `git-identity.sh` does not affect jj commits.

## tmux + worktree workflow

Root-level scripts are bound in `config/tmux/tmux.conf`:
- `tmux-sessionizer.sh` (`prefix f`, `prefix d` for this repo): fzf over `~/projects` and `~/oss-projects`, opens or switches to a session.
- `tmux-worktree-picker.sh` (`prefix W`): fzf over `git worktree list` for the current repo, opens a window named after the branch.
- `tmux-wt-spawn.sh` (`prefix C`): creates a worktree for a branch off the main checkout and opens a window running `claude` in it.
- `tmux-claude-picker.sh` (`prefix A`): lists windows tagged `@claude=1`; windows with `monitor-silence` firing (Claude likely waiting for input) sort first.

`zshrc` also wraps the `wt` command so `wt switch` opens or selects a tmux window named after the branch.

## Version control

The repo is colocated git + Jujutsu (`.jj/`, `trunk()` = `main@origin`), and jj keeps git on a detached HEAD. Check `jj log` as well as `git status` before committing or pushing: a local checkout can be on an older line than `main`. Remote: `https://github.com/randuck-dev/dotfiles`.
