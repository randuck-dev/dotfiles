dd
# Dotfile setup

This setup is mostly leveraging nix to setup my machine.

## NIX Setup

**Install Determinate**:
- [Check here](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#determinate-nix-installer)

**Fixes for brew**:

```bash
sudo mkdir -p /opt/homebrew/Library/Taps/homebrew/ && sudo /bin/chmod +a "$USER allow list,add_file,search,delete,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,chown" /opt/homebrew/Library/Taps
```
