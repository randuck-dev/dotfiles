
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Skipping linux: OSTYPE is $OSTYPE"
    return
fi


echo "Running on linux"

if [[ -x "$(command -v ansible)" ]]; then
    echo "ansible found"
    return
fi

export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt install -y ansible

export DEBIAN_FRONTEND=dialog