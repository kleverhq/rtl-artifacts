#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/release.sh <version>

Create a GitHub release for <version>, ensure artifacts are collected,
and upload every file from artifacts/ as individual release assets.
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

target_commit="$(git rev-parse HEAD)"

artifacts_dir="${ARTIFACTS_DIR:-artifacts}"
dockerfile_path=".devcontainer/Dockerfile"

if [[ ! -f "$dockerfile_path" ]]; then
  echo "Error: '$dockerfile_path' is required to extract pinned RTL SHAs."
  exit 1
fi

chipyard_sha="$(git -C /opt/chipyard rev-parse HEAD 2>/dev/null || true)"
scr1_sha="$(awk -F= '/^ARG SCR1_COMMIT=/{print $2; exit}' "$dockerfile_path")"
picorv32_sha="$(awk -F= '/^ARG PICORV32_COMMIT=/{print $2; exit}' "$dockerfile_path")"

if [[ -z "$chipyard_sha" ]]; then
  echo "Error: failed to resolve Chipyard SHA from /opt/chipyard."
  exit 1
fi

if [[ -z "$scr1_sha" || -z "$picorv32_sha" ]]; then
  echo "Error: failed to parse SCR1/PicoRV32 SHAs from $dockerfile_path."
  exit 1
fi

echo "Collecting artifacts (incremental via make targets)..."
make collect

if [[ ! -d "$artifacts_dir" ]]; then
  echo "Error: artifacts directory '$artifacts_dir' does not exist."
  exit 1
fi

mapfile -d '' artifacts < <(find "$artifacts_dir" -type f -print0 | sort -z)

if (( ${#artifacts[@]} == 0 )); then
  echo "Error: no files found in '$artifacts_dir'."
  exit 1
fi

declare -A seen_asset_names
for file in "${artifacts[@]}"; do
  asset_name="${file##*/}"
  if [[ -n "${seen_asset_names[$asset_name]:-}" ]]; then
    echo "Error: duplicate artifact filename '$asset_name' in '$file' and '${seen_asset_names[$asset_name]}'."
    echo "GitHub release assets require unique filenames."
    exit 1
  fi
  seen_asset_names["$asset_name"]="$file"
done

notes_file="$(mktemp)"
trap 'rm -f "$notes_file"' EXIT

cat >"$notes_file" <<EOF
## RTL SHAs
- Chipyard: \`$chipyard_sha\`
- SCR1: \`$scr1_sha\`
- PicoRV32: \`$picorv32_sha\`

## Artifacts
- Uploaded files: ${#artifacts[@]}
- Source directory: \`$artifacts_dir/\`
EOF

echo "Creating GitHub release '$version' and uploading ${#artifacts[@]} assets..."
gh release create "$version" "${artifacts[@]}" --title "$version" --notes-file "$notes_file" --target "$target_commit"

release_url="$(gh release view "$version" --json url --jq '.url')"
echo "Release created: $release_url"
