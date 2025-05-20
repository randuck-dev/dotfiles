#!/bin/bash
SDK_VERSIONS=("9.0" "8.0" "6.0")

install_dotnet_sdk() {
  local version=$1
  if command -v dotnet | dotnet --list-sdks | grep -q "$version"; then
    echo ".NET SDK $version is already installed."
  else
    echo "Installing .NET SDK $version..."
    wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x dotnet-install.sh
    ./dotnet-install.sh --channel $version
    rm dotnet-install.sh
  fi
}

for version in "${SDK_VERSIONS[@]}"; do
  install_dotnet_sdk $version
done

echo "All specified SDKs have been processed."
