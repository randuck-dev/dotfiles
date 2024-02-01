
# If not macos then return
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Skipping macos: OSTYPE is $OSTYPE"
    return
fi

ALACRITTY_DIR="$HOME/.config/alacritty"
ALACRITTY_THEMES_DIR="$ALACRITTY_DIR/themes"

echo "Running on mac"
if ! [ -x "$(command -v brew)" ]; then
    echo "brew not found. Installing it..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "brew found"
fi

if ! [ -x "$(command -v ansible)" ]; then
    echo "ansible not found. installing it..."
    brew install ansible
else
    echo "ansible found"
fi
if ! [ -d $ALACRITTY_THEMES_DIR ]; then
    echo "alacritty themes not found"
    mkdir -p ~/.config/alacritty/themes

    git clone -b yaml https://github.com/alacritty/alacritty-theme $ALACRITTY_THEMES_DIR

else
    echo "alacritty themes found"
fi

ln -sf "$DOTFILES_DIR/alacritty.yml" "$ALACRITTY_DIR/alacritty.yml"

