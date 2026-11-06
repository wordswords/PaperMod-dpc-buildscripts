#!/bin/zsh

set -e
set -x

git submodule update --init --recursive

find ./content/ -name '*.md' -type f -exec perl -0777 -pi -e 's/\{\{\/\*.*?\*\/\}\}//gs' {} \;
git add ./content/
git commit -m "Latest hugo update" || echo ''
git push origin main
./github-repo.sh
./themes/PaperMod-dpc/scripts/fetch-git-hashes.sh
git add ./static/
git commit -m "Latest hash update" || echo ''
sleep 600
git push origin main
