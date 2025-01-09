# If not macos then return
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "Skipping macos: OSTYPE is $OSTYPE"
  return
fi

ALACRITTY_DIR="$HOME/.config/alacritty"
ALACRITTY_THEMES_DIR="$ALACRITTY_DIR/themes"

echo "Running on mac"
