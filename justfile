
set working-directory := 'config/nix-config'

build machine:
    echo "Starting build..."
    nix build --extra-experimental-features 'nix-command flakes' .#darwinConfigurations.{{ machine }}.system --show-trace
    unlink ./result


switch machine:
    nix build --extra-experimental-features 'nix-command flakes' .#darwinConfigurations.{{ machine }}.system --show-trace
    ./result/sw/bin/darwin-rebuild switch --flake .#{{ machine }} --show-trace
    unlink result

update:
    nix flake update

