#!/usr/bin/env bash
# Print the current repository's GitHub owner/repo and save it as a static JSON asset.
set -euo pipefail

if ! remote_url=$(git remote get-url origin); then
    printf 'Error: run inside a Git repository with an origin remote.\n' >&2
    exit 1
fi

pattern='^(https?://github\.com/|git@github\.com:|ssh://git@github\.com/)([A-Za-z0-9-]+)/([A-Za-z0-9_.-]+)/?$'
if [[ ! $remote_url =~ $pattern ]]; then
    printf 'Error: origin is not a recognized GitHub URL: %s\n' "$remote_url" >&2
    exit 1
fi

owner=${BASH_REMATCH[2]}
repo=${BASH_REMATCH[3]%.git}
if [[ -z $repo ]]; then
    printf 'Error: origin has an empty repository name.\n' >&2
    exit 1
fi
repo_root=$(git rev-parse --show-toplevel)
output_dir="$repo_root/hugo-site/static"
mkdir -p "$output_dir"
# The validated owner and repo contain no characters requiring JSON escaping.
printf '{\n  "repo": "%s/%s"\n}\n' "$owner" "$repo" > "$output_dir/github-repo.json"

printf '%s/%s\n' "$owner" "$repo"
