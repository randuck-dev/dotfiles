{ pkgs }:
pkgs.callPackage
  (pkgs.fetchFromGitHub {
    owner = "randuck-dev";
    repo = "brightnessctl-rs";
    rev = "a36cdca8794e7c47d40ad93c69c398a84e37adda";
    sha256 = "LiPQRcNkRB77Rj98gzO2d/fh8PTI43avpsqjeGOsGHg=";
  })
{ }
