if [ $(uname) != 'Darwin' ]; then
  echo 'Skipping initialization of brew packages'
else
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  echo $script_dir
  runs_dir=$(find $script_dir/pkgs -mindepth 1 -maxdepth 1)

  for s in $runs_dir; do
    if basename $s | grep -vq "$grep"; then
      log "grep \"$grep\" filtered out $s"
      continue
    fi

    log "running script: $s"

    if [[ $dry_run == "0" ]]; then
      $s
    fi
  done
fi
