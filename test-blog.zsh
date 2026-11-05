#!/bin/zsh

set -e
set -x

git submodule update --init --recursive

find ./content/ -name '*.md' -type f -exec perl -0777 -pi -e 's/\{\{\/\*.*?\*\/\}\}//gs' {} \;
hugo --gc --config ./hugo.yaml
hugo server --bind 0.0.0.0 --buildDrafts --config ./hugo.yaml --disableFastRender

