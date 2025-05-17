sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo $ZSH_CUSTOM
install_path="$ZSH_CUSTOM/plugins/autoswitch_virtualenv"
echo "Installing autoswitch_virtualenv: $install_path"
if [ ! -d $install_path ]; then
  git clone "https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv.git" $install_path
fi

install_path="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
echo "Installing zsh-autosuggestions: $install_path"
if [ ! -d $install_path ]; then
  git clone "https://github.com/zsh-users/zsh-autosuggestions" $install_path
fi
