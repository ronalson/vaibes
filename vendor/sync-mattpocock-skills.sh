#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
remote="${MATTPOCOCK_SKILLS_REMOTE:-https://github.com/mattpocock/skills.git}"
tmp_dir=""

cleanup() {
  if [[ -n "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required to sync selected skill directories." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to fetch the upstream skills repository." >&2
  exit 1
fi

if [[ -n "${MATTPOCOCK_SKILLS_SOURCE:-}" ]]; then
  source_dir="$MATTPOCOCK_SKILLS_SOURCE"

  if [[ ! -d "$source_dir/.git" ]]; then
    echo "Expected a git checkout at: $source_dir" >&2
    exit 1
  fi
else
  tmp_dir="$(mktemp -d)"
  source_dir="$tmp_dir/mattpocock-skills"

  git clone --depth 1 "$remote" "$source_dir"
fi

source_commit="$(git -C "$source_dir" rev-parse --short HEAD)"

sync_skill() {
  local name="$1"
  local upstream_path="$2"
  local src="$source_dir/$upstream_path"
  local dest="$repo_root/skills/$name"

  if [[ ! -d "$src" ]]; then
    echo "Missing upstream skill directory: $src" >&2
    exit 1
  fi

  mkdir -p "$dest"
  rsync -a --delete --exclude '.DS_Store' "$src/" "$dest/"
}

sync_skill "tdd" "skills/engineering/tdd"
sync_skill "codebase-design" "skills/engineering/codebase-design"
sync_skill "prototype" "skills/engineering/prototype"

cp "$source_dir/LICENSE" "$repo_root/vendor/mattpocock-skills-LICENSE"

cat > "$repo_root/vendor/mattpocock-skills.json" <<JSON
{
  "remote": "$remote",
  "sourceCommit": "$source_commit",
  "license": "vendor/mattpocock-skills-LICENSE",
  "skills": {
    "tdd": "skills/engineering/tdd",
    "codebase-design": "skills/engineering/codebase-design",
    "prototype": "skills/engineering/prototype"
  }
}
JSON

echo "Synced Matt Pocock skill picks from $source_commit."
echo "Review changes with: git diff -- skills vendor/mattpocock-skills.json vendor/mattpocock-skills-LICENSE"
