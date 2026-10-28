# Asks once for extra git identities and keeps them in files outside this repo.
# Each identity applies to repos whose remote is under a given GitHub owner (user or org).
# Run again after deleting ~/.gitconfig.local.

local_config="$HOME/.gitconfig.local"

if [ -f "$local_config" ]; then
  echo "Git identities: $local_config exists, skipping (delete it to set them up again)"
elif [ ! -t 0 ] || [ -n "$CI" ]; then
  echo "Git identities: not running interactively, skipping"
else
  echo "Git identities: the default email is $(git config --file "$DOTFILES_DIR/config/git/config" user.email)"
  touch "$local_config"
  while true; do
    read -r -p "GitHub owner that needs a different email (empty to finish): " owner
    [ -z "$owner" ] && break
    read -r -p "Email for $owner repos: " email
    if [ -z "$email" ]; then
      echo "> No email given, skipping $owner"
      continue
    fi
    read -r -p "Name for $owner repos (empty keeps the default): " name

    slug=$(echo "$owner" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_.-')
    identity_file="$HOME/.gitconfig.$slug"
    git config --file "$identity_file" user.email "$email"
    if [ -n "$name" ]; then
      git config --file "$identity_file" user.name "$name"
    fi
    for url in "https://github.com/$owner/**" "git@github.com:$owner/**"; do
      git config --file "$local_config" --add "includeIf.hasconfig:remote.*.url:$url.path" "$identity_file"
    done
    echo "> Repos under github.com/$owner will use $email"
  done
fi
