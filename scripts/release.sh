#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/release.sh <version>

Create a GitHub release for <version>, collect artifacts incrementally by default,
and upload every file reported by `make list` as an individual release asset.
Nested artifact paths are staged under unique flat filenames by replacing '/' with
'__'.

The worktree must be clean so release assets and notes match the target commit.
Set ALLOW_DIRTY=1 only for a deliberate local dry run.
Set SKIP_COLLECT=1 only when artifacts were already collected and verified.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

version="$1"

for cmd in gh make git awk find sort mktemp; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command '$cmd' not found in PATH."
    exit 1
  fi
done

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "Error: this script must run inside a git repository."
  exit 1
fi

cd "$repo_root"

if ! gh auth status >/dev/null 2>&1; then
  echo "Error: gh is not authenticated. Run 'gh auth login' first."
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1 && [[ -z "${GH_REPO:-}" ]]; then
  echo "Error: no 'origin' remote configured and GH_REPO is not set."
  exit 1
fi

if gh release view "$version" >/dev/null 2>&1; then
  echo "Error: release '$version' already exists."
  exit 1
fi

mapfile -t version_files < <(find projects -mindepth 2 -maxdepth 2 -name versions.mk | sort)
if (( ${#version_files[@]} == 0 )); then
  echo "Error: no project versions.mk files found."
  exit 1
fi

if [[ "${ALLOW_DIRTY:-0}" != "1" ]]; then
  git update-index -q --refresh
  if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    echo "Error: worktree is dirty. Commit changes before releasing, or set ALLOW_DIRTY=1 for a deliberate dry run."
    exit 1
  fi
fi

target_commit="$(git rev-parse HEAD)"
artifacts_dir="${ARTIFACTS_DIR:-artifacts}"

if [[ "${SKIP_COLLECT:-0}" == "1" ]]; then
  echo "Skipping artifact collection because SKIP_COLLECT=1."
else
  echo "Collecting artifacts (incremental via make targets)..."
  ARTIFACTS_DIR="$artifacts_dir" make --no-print-directory collect
fi

if [[ ! -d "$artifacts_dir" ]]; then
  echo "Error: artifacts directory '$artifacts_dir' does not exist."
  exit 1
fi

artifacts_dir_abs="$(cd "$artifacts_dir" && pwd)"

mapfile -t artifacts < <(ARTIFACTS_DIR="$artifacts_dir_abs" make --no-print-directory list | sort)
if (( ${#artifacts[@]} == 0 )); then
  echo "Error: make list produced no artifacts."
  exit 1
fi

declare -A listed_artifacts
for file in "${artifacts[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: listed artifact does not exist: $file"
    exit 1
  fi
  listed_artifacts["$file"]=1
done

mapfile -d '' existing_files < <(find "$artifacts_dir_abs" -type f -print0 | sort -z)
for file in "${existing_files[@]}"; do
  if [[ -z "${listed_artifacts[$file]:-}" ]]; then
    echo "Error: unlisted artifact exists and would make release ambiguous: $file"
    echo "Remove stale artifacts or add the file to a project list target."
    exit 1
  fi
done

stage_dir="$(mktemp -d "$artifacts_dir_abs/.release-upload.XXXXXX")"
notes_file="$(mktemp)"
trap 'rm -rf "$stage_dir"; rm -f "$notes_file"' EXIT

declare -A seen_asset_names
release_assets=()
for file in "${artifacts[@]}"; do
  rel="${file#"$artifacts_dir_abs"/}"
  asset_name="${rel//\//__}"
  if [[ -n "${seen_asset_names[$asset_name]:-}" ]]; then
    echo "Error: duplicate release asset name '$asset_name' from '$file' and '${seen_asset_names[$asset_name]}'."
    exit 1
  fi
  seen_asset_names["$asset_name"]="$file"
  staged_file="$stage_dir/$asset_name"
  if ! ln "$file" "$staged_file" 2>/dev/null; then
    cp -p "$file" "$staged_file"
  fi
  release_assets+=("$staged_file")
done

{
  echo '## Project version pins'
  for file in "${version_files[@]}"; do
    project="${file#projects/}"
    project="${project%%/*}"
    echo "- ${project} (\`$file\`)"
    awk '
      /^[[:space:]]*#/ { next }
      /^[[:space:]]*$/ { next }
      /^[[:space:]]*[A-Za-z0-9_]+[[:space:]]*(:=|=)/ {
        key=$0
        sub(/^[[:space:]]*/, "", key)
        sub(/[[:space:]]*(:=|=).*/, "", key)
        value=$0
        sub(/^[^:=]*(:=|=)[[:space:]]*/, "", value)
        printf "  - `%s`: `%s`\n", key, value
      }
    ' "$file"
  done
  echo
  echo '## Artifacts'
  echo "- Uploaded files: ${#artifacts[@]}"
  echo "- Source directory: \`$artifacts_dir_abs/\`"
} >"$notes_file"

echo "Creating GitHub release '$version' and uploading ${#artifacts[@]} assets..."
gh release create "$version" "${release_assets[@]}" --title "$version" --notes-file "$notes_file" --target "$target_commit"

release_url="$(gh release view "$version" --json url --jq '.url')"
echo "Release created: $release_url"
