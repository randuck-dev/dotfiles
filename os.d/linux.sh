
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Skipping linux: OSTYPE is $OSTYPE"
    return
fi


echo "Running on linux"

CONFIG=$HOME/.config

symlink() {
    target_folder=$(basename $1)
    target_folder=$2/$target_folder

    if [[ -f "$2/.owners" ]]; then
        if grep -q $1 $2/.owners; then
            echo "Skipping $1, already symlinked"
            return
        fi
    fi
    if [[ -d "$target_folder" ]]; then
        echo "Backing up $target_folder to $target_folder.bak"
        mv $target_folder $target_folder.bak
    fi

    echo "Symlinking $1 to $2"
    ln -s $1 $2
    echo $1 >> $2/.owners
}


for folder in $DOTFILES_DIR/config/*; do
    folder_name=$(basename $folder)
    echo "Symlinking $folder to $CONFIG/"
    symlink $folder $CONFIG/
done


if [[ -x "$(command -v ansible)" ]]; then
    echo "ansible found"
    return
fi

if grep -q -i "fedora" /etc/os-release; then
    sudo dnf install ansible
    return
fi

export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y ansible

export DEBIAN_FRONTEND=dialog
