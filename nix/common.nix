# Packages and fonts shared by every machine (NixOS and macOS).
# Platform-only packages go in nix/configuration.nix (NixOS) or nix/darwin.nix (macOS).
{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Shell and editors
    tmux
    neovim
    helix
    fzf
    ripgrep
    jq
    bat
    btop
    htop
    wget
    unzip
    sqlite
    watch
    just

    # Git
    git
    gh
    lazygit
    worktrunk

    # Languages and tooling
    nodejs_24
    python314
    uv
    ruff
    devenv

    # Infra
    terraform
    k9s
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
    font-awesome
    maple-mono.truetype
    maple-mono.NF-unhinted
    maple-mono.NF-CN-unhinted
  ];
}
