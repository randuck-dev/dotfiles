# If not macos then return
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "Skipping macos: OSTYPE is $OSTYPE"
  return
fi

echo "Running on mac"
