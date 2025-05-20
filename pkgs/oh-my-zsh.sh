sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Restore original .zshrc if .zshrc.pre-oh-my-zsh exists
if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
  echo "Restoring original .zshrc file..."
  rm -f "$HOME/.zshrc"
  mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
fi

install_path="$HOME/.oh-my-zsh/custom/plugins/autoswitch_virtualenv"
echo "Installing autoswitch_virtualenv: $install_path"
if [ ! -d $install_path ]; then
  git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" $install_path
fi

install_path="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
echo "Installing zsh-autosuggestions: $install_path"
if [ ! -d $install_path ]; then
  git clone "https://github.com/zsh-users/zsh-autosuggestions" $install_path
fi
