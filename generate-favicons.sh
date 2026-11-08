#!/usr/bin/env bash
# Generate PaperMod's additional icons without modifying the source ICO.
set -euo pipefail

usage() {
  printf 'Usage: %s INPUT.ico [OUTPUT_DIRECTORY]\n' "${0##*/}"
  printf '\nGenerate favicon-16x16.png, favicon-32x32.png, apple-touch-icon.png,\n'
  printf 'and safari-pinned-tab.svg. Output defaults to the input directory.\n'
  printf 'Existing generated icons are overwritten; the source ICO is preserved.\n'
  printf '\nDependencies: ImageMagick (7 or 6) and Potrace.\n'
  printf 'Debian/Ubuntu: sudo apt install imagemagick potrace\n'
  printf 'macOS: brew install imagemagick potrace\n'
}

if [[ ${1:-} == --help || ${1:-} == -h ]]; then
  usage
  exit 0
fi
if (( $# < 1 || $# > 2 )); then
  usage >&2
  exit 1
fi

input=$1
[[ $input == /* ]] || input="$PWD/$input"
if [[ ! -f $input || ! -r $input ]]; then
  printf 'Error: input is not a readable file: %s\n' "$input" >&2
  exit 1
fi
output=${2:-$(dirname "$input")}

if command -v magick >/dev/null 2>&1; then
  image=(magick)
  identify=(magick identify)
elif command -v convert >/dev/null 2>&1 && command -v identify >/dev/null 2>&1; then
  image=(convert)
  identify=(identify)
else
  printf 'Error: ImageMagick is required. Run with --help for installation instructions.\n' >&2
  exit 1
fi
if ! command -v potrace >/dev/null 2>&1; then
  printf 'Error: Potrace is required for the Safari SVG. Run with --help for installation instructions.\n' >&2
  exit 1
fi

# ICO files often contain multiple resolutions. Select the largest frame.
frame=$("${identify[@]}" -format '%w %h\n' "$input" | awk '
  $1 * $2 > largest { largest = $1 * $2; frame = NR - 1 }
  END { if (NR == 0) exit 1; print frame + 0 }
')

mkdir -p -- "$output"
work=$(mktemp -d "$output/.generate-favicons.XXXXXX")
trap 'rm -rf -- "$work"' EXIT

for size in 16 32 180; do
  case $size in
    180) name=apple-touch-icon.png ;;
    *) name="favicon-${size}x${size}.png" ;;
  esac
  "${image[@]}" "${input}[$frame]" -auto-orient \
    -resize "${size}x${size}" -gravity center -background none \
    -extent "${size}x${size}" "$work/$name"
done

# Safari needs monochrome vector paths, not a raster embedded in an SVG.
# Flatten transparency onto white and trace the dark regions of the icon.
# A dedicated simplified logo may look better than an automatically traced ICO.
"${image[@]}" "${input}[$frame]" -auto-orient \
  -background white -alpha remove -alpha off \
  -colorspace Gray -threshold 50% "$work/mask.pbm"
potrace "$work/mask.pbm" --svg --output "$work/safari-pinned-tab.svg"

# Publish only after all conversions have succeeded.
for name in favicon-16x16.png favicon-32x32.png apple-touch-icon.png safari-pinned-tab.svg; do
  mv -f -- "$work/$name" "$output/$name"
  printf 'Generated %s\n' "$output/$name"
done
