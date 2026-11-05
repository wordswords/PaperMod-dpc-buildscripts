#!/bin/bash

set -e
postslug=$1
if [ -z "${postslug}" ]; then
    echo "Usage: $0 <post-slug-name>"
    exit 1
fi

git submodule update --init --recursive

rm -rf content/posts/${postslug}
rm -rf content/posts/${postslug}.md

hugo new content content/posts/${postslug}.md
rm content/posts/${postslug}.md
mkdir -p content/posts/${postslug}
cp ./default-post-template.md content/posts/${postslug}/index.md
vim content/posts/${postslug}/index.md

echo "Now put images in $(pwd)/content/posts/$1/ !"
echo "e.g. scp *.jpg david@hq.local:$(pwd)/content/posts/$1/"

