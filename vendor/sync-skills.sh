#!/usr/bin/env bash
# Sync every tracked third-party skill into skills/ from vendor/*-skills.json.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
vendor_dir="$repo_root/vendor"

if ! command -v rsync >/dev/null 2>&1; then
  echo "rsync is required." >&2
  exit 1
fi
if ! command -v git >/dev/null 2>&1; then
  echo "git is required." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required." >&2
  exit 1
fi

apply_frontmatter_name() {
  local skill_md="$1"
  local local_name="$2"
  python3 - "$skill_md" "$local_name" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
local_name = sys.argv[2]
text = path.read_text()
if not text.startswith("---"):
    raise SystemExit(f"missing frontmatter: {path}")
parts = text.split("---", 2)
if len(parts) < 3:
    raise SystemExit(f"malformed frontmatter: {path}")
fm = parts[1]
fm2, n = re.subn(r"(?m)^name:\s*.*$", f"name: {local_name}", fm, count=1)
if n != 1:
    raise SystemExit(f"could not rewrite name: in {path}")
path.write_text(f"---{fm2}---{parts[2]}")
PY
}

sync_track() {
  local track_file="$1"
  local tmp_dir=""
  local source_dir=""

  cleanup() {
    if [[ -n "${tmp_dir:-}" ]]; then
      rm -rf "$tmp_dir"
    fi
  }
  trap cleanup RETURN

  eval "$(python3 - "$track_file" <<'PY'
import json, shlex, sys
from pathlib import Path
track = json.loads(Path(sys.argv[1]).read_text())
print(f"remote={shlex.quote(track['remote'])}")
print(f"license_rel={shlex.quote(track.get('license') or '')}")
skills = track["skills"]
# Encode skills as lines: local|path|rename
print("skills_blob=$(cat <<'SKILLS_EOF'")
for local, spec in skills.items():
    if isinstance(spec, str):
        path, rename = spec, ""
    else:
        path = spec["path"]
        rename = spec.get("rename") or ""
    print(f"{local}|{path}|{rename}")
print("SKILLS_EOF")
print(")")
PY
)"

  tmp_dir="$(mktemp -d)"
  source_dir="$tmp_dir/upstream"
  git clone --depth 1 "$remote" "$source_dir"
  local source_commit
  source_commit="$(git -C "$source_dir" rev-parse --short HEAD)"

  while IFS='|' read -r local_name upstream_path rename_from; do
    [[ -z "$local_name" ]] && continue
    local src="$source_dir/$upstream_path"
    local dest="$repo_root/skills/$local_name"
    if [[ ! -d "$src" ]]; then
      echo "Missing upstream skill directory: $src" >&2
      exit 1
    fi
    mkdir -p "$dest"
    rsync -a --delete --exclude '.DS_Store' "$src/" "$dest/"
    if [[ -n "$rename_from" ]]; then
      apply_frontmatter_name "$dest/SKILL.md" "$local_name"
    fi
  done <<< "$skills_blob"

  if [[ -n "$license_rel" ]]; then
    local license_src="$source_dir/LICENSE"
    if [[ ! -f "$license_src" ]]; then
      echo "Track expects LICENSE but upstream has none: $remote" >&2
      exit 1
    fi
    cp "$license_src" "$repo_root/$license_rel"
  fi

  python3 - "$track_file" "$source_commit" <<'PY'
import json
import sys
from pathlib import Path

track_path = Path(sys.argv[1])
source_commit = sys.argv[2]
track = json.loads(track_path.read_text())
track["sourceCommit"] = source_commit
# Normalize skills entries to objects
normalized = {}
for local, spec in track["skills"].items():
    if isinstance(spec, str):
        normalized[local] = {"path": spec}
    else:
        entry = {"path": spec["path"]}
        if spec.get("rename"):
            entry["rename"] = spec["rename"]
        normalized[local] = entry
track["skills"] = normalized
track_path.write_text(json.dumps(track, indent=2) + "\n")
PY

  echo "Synced $(basename "$track_file") from $source_commit."
}

shopt -s nullglob
tracks=("$vendor_dir"/*-skills.json)
if ((${#tracks[@]} == 0)); then
  echo "No vendor/*-skills.json track files found." >&2
  exit 1
fi

for track in "${tracks[@]}"; do
  sync_track "$track"
done

echo "Review with: git diff -- skills vendor"
