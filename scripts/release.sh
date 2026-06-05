#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/release.sh <version>

Create a GitHub release for <version>, collect artifacts incrementally, and
upload every file from artifacts/ as an individual release asset. Nested
artifact paths are converted to unique asset names by replacing '/' with '__'.
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

read_var() {
  local file="$1"
  local name="$2"
  awk -v name="$name" '
    $0 ~ "^[[:space:]]*" name "[[:space:]]*(:=|=)" {
      sub("^[^:=]*(:=|=)[[:space:]]*", "")
      print
      exit
    }
  ' "$file"
}

required_versions=(
  projects/scr1/versions.mk
  projects/picorv32/versions.mk
  projects/chipyard/versions.mk
  projects/tb_complex_types/versions.mk
)

for file in "${required_versions[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Error: missing version file '$file'."
    exit 1
  fi
done

scr1_sha="$(read_var projects/scr1/versions.mk SCR1_COMMIT)"
picorv32_sha="$(read_var projects/picorv32/versions.mk PICORV32_COMMIT)"
chipyard_sha="$(read_var projects/chipyard/versions.mk CHIPYARD_COMMIT)"
verilator_version="$(read_var projects/scr1/versions.mk VERILATOR_VERSION)"
riscv_xpack_version="$(read_var projects/scr1/versions.mk RISCV_XPACK_VERSION)"
miniforge_version="$(read_var projects/chipyard/versions.mk MINIFORGE_VERSION)"

if [[ -z "$scr1_sha" || -z "$picorv32_sha" || -z "$chipyard_sha" ]]; then
  echo "Error: failed to parse project commit pins from versions.mk files."
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
release_assets=()
for file in "${artifacts[@]}"; do
  rel="${file#"$artifacts_dir"/}"
  asset_name="${rel//\//__}"
  if [[ -n "${seen_asset_names[$asset_name]:-}" ]]; then
    echo "Error: duplicate release asset name '$asset_name' from '$file' and '${seen_asset_names[$asset_name]}'."
    exit 1
  fi
  seen_asset_names["$asset_name"]="$file"
  release_assets+=("$file#$asset_name")
done

notes_file="$(mktemp)"
trap 'rm -f "$notes_file"' EXIT

cat >"$notes_file" <<EOF
## RTL source pins
- SCR1: \`$scr1_sha\`
- PicoRV32: \`$picorv32_sha\`
- Chipyard: \`$chipyard_sha\`

## Tool pins
- Verilator for SCR1/Chipyard images: \`$verilator_version\`
- RISC-V xPack toolchain for SCR1/PicoRV32 images: \`$riscv_xpack_version\`
- Miniforge for Chipyard image: \`$miniforge_version\`

## Artifacts
- Uploaded files: ${#artifacts[@]}
- Source directory: \`$artifacts_dir/\`
EOF

echo "Creating GitHub release '$version' and uploading ${#artifacts[@]} assets..."
gh release create "$version" "${release_assets[@]}" --title "$version" --notes-file "$notes_file" --target "$target_commit"

release_url="$(gh release view "$version" --json url --jq '.url')"
echo "Release created: $release_url"
