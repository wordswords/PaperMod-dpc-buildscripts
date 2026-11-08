#!/bin/bash

set -e
set -x

PD=$(pwd)

ln -sf ${PD}/default-post-template.md ../default-post-template.md
ln -sf ${PD}/github-repo.sh ../github-repo.sh
ln -sf ${PD}/new-post.zsh ../new-post.zsh
ln -sf ${PD}/publish-post.zsh ../publish-post.zsh
ln -sf ${PD}/test-blog.zsh ../test-blog.zsh
ln -sf ${PD}/generate-favicons.sh ../generated-favicons.sh



