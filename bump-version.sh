#!/usr/bin/bash

# fetch version of pandoc-bin aur package
source <(curl -sSL "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pandoc-bin")

# replace docker tag pins
git ls-files | xargs sed -E -i "/PANDOC_VERSION/s/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/$pkgver/"

# commit changes
git add --all && git commit -m "bump pandoc version to aur latest ($pkgver)"
