# randuck-dev [dotfiles]

Run the following to bootstrap the entire system. Sit back, relax and take a sip of your delicious coffee!

```sh
./dev.sh
```

On macOS, install [Homebrew](https://brew.sh) and Nix ([Lix](https://lix.systems/install)) first. `dev.sh` then applies the Nix flake's macOS config, which installs the dev tools and desktop apps. On NixOS, apply the system config with `athena-update`.

`dev.sh` asks once whether some GitHub users or orgs need a different git email (for example on a work machine). The answers are stored outside the repo in `~/.gitconfig.local` and `~/.gitconfig.<owner>`. Delete `~/.gitconfig.local` to be asked again.
