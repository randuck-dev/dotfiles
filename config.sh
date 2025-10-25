CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/.dotfiles"
echo "Linking configuration files"
mkdir -p "$CONFIG_DIR"

for dir in $DOTFILES_DIR/config/*; do
  target_dir="$CONFIG_DIR/$(basename $dir)"
  if [ ! -d $target_dir ]; then
    echo "> Creating symlink for $dir in $target_dir"
    ln -sf $dir $target_dir
  else
    echo "> $target_dir already exists"
  fi
done
echo "Finished linking configuration files"
