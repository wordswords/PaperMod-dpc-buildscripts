#!/bin/bash

set -e
set -x

ln -sf ./default-post-template.md ../default-post-template.md
ln -sf ./github-repo-sh ../github-repo.sh
ln -sf ./new-post.zsh ../new-post.zsh
ln -sf ./publish-post.zsh ../publish-post.zsh
ln -sf ./test-blog.zsh ../test-blog.zsh

