#!/usr/bin/env bash
# Build a static Composer repository that re-serves wpsecadv advisories under
# our own package names, as listed in aliases.json.
#
# Usage: build.sh <out-dir> <base-url>
set -euo pipefail

out=$1
base_url=${2%/}
source_url=${WPSECADV_URL:-https://repo-wpsecadv.typist.tech}
here=$(cd "$(dirname "$0")" && pwd)

rm -rf "$out"
mkdir -p "$out/p2"

while IFS=$'\t' read -r package source; do
  mkdir -p "$out/p2/$(dirname "$package")"
  tmp=$(mktemp)
  code=$(curl -sS -o "$tmp" -w '%{http_code}' "$source_url/p2/$source.json")
  case "$code" in
    200)
      # Fail rather than publish something Composer can't read.
      jq -e '."security-advisories" | type == "array"' "$tmp" > /dev/null
      jq -c '{packages: [], "security-advisories": ."security-advisories"}' "$tmp" > "$out/p2/$package.json"
      ;;
    404)
      # wpsecadv has no advisories for the source slug (yet).
      echo '{"packages":[],"security-advisories":[]}' > "$out/p2/$package.json"
      ;;
    *)
      echo "::error::$source_url/p2/$source.json returned HTTP $code" >&2
      exit 1
      ;;
  esac
  rm -f "$tmp"
  printf '%s <- %s: %s advisories\n' "$package" "$source" \
    "$(jq '."security-advisories" | length' "$out/p2/$package.json")"
done < <(jq -r 'to_entries[] | [.key, .value] | @tsv' "$here/aliases.json")

# metadata-url must be absolute: Composer resolves a leading "/" against the
# host, which would drop the GitHub Pages project path.
jq -n \
  --arg url "$base_url/p2/%package%.json" \
  --slurpfile aliases "$here/aliases.json" \
  '{
    "metadata-url": $url,
    "available-packages": ($aliases[0] | keys),
    "security-advisories": {metadata: true}
  }' > "$out/packages.json"
