# randuck-dev [dotfiles]

Run the following to bootstrap the entire system. Sit back, relax and take a sip of your delicious coffee!

```sh
./dev.sh
```

> [!NOTE]
> This installation assumes MacOS.

`dev.sh` asks once whether some GitHub users or orgs need a different git email (for example on a work machine). The answers are stored outside the repo in `~/.gitconfig.local` and `~/.gitconfig.<owner>`. Delete `~/.gitconfig.local` to be asked again.
