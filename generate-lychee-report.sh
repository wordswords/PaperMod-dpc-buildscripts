#!/bin/bash

set -x
set -e

mkdir -p ./link-reports
./test-blog.zsh &
sleep 10

sudo docker run --rm --init \
  --network host \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=$(pwd)/public,target=/site,readonly" \
  --mount "type=bind,source=$(pwd)/link-reports,target=/reports" \
  lycheeverse/lychee:latest \
  --root-dir /site \
  --remap '^https?://localhost(:[0-9]+)?/ http://localhost:1313/' \
  --remap '^file:///site/ http://localhost:1313/' \
  --remap '^https?://YOUR-DOMAIN\.example([/?#]|$) http://localhost:1313$1' \
  --include-fragments \
  --format detailed \
  --output /reports/lychee-errors.txt \
  '/site/**/*.html'

scan_status=$?

cat ./link-reports/lychee-errors.txt
printf '\nLychee exit status: %s\n' "$scan_status"
