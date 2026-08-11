#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd -- "$script_dir/.." && pwd)
cleanup_list_file="$script_dir/cleanup-files"
cleanup_directory="$repo_root/out"
move_artifacts=1

resolve_cleanup_directory() {
  local target=$1

  if [[ "$target" = /* ]]; then
    printf '%s\n' "$target"
  else
    printf '%s/%s\n' "$repo_root" "$target"
  fi
}

if [[ -n "${1:-}" ]]; then
  if [[ "$1" == "--no-move" ]]; then
    move_artifacts=0
  else
    cleanup_directory=$(resolve_cleanup_directory "$1")
  fi
fi

if [[ -n "${2:-}" ]]; then
  if [[ "$2" == "--no-move" ]]; then
    move_artifacts=0
  else
    cleanup_directory=$(resolve_cleanup_directory "$2")
  fi
fi

if [[ ! -f "$cleanup_list_file" ]]; then
  printf 'ERROR: Cleanup list not found at %s.\n' "$cleanup_list_file" >&2
  exit 1
fi

echo "SCRIPT: CLEANUP"
echo "Cleaning up build generated files from '$cleanup_list_file'."
echo "Directory: $cleanup_directory"
echo

shopt -s nullglob
while IFS= read -r token; do
  [[ -z "$token" || "$token" == \#* ]] && continue

  for path in "$cleanup_directory"/$token; do
    [[ -e "$path" || -L "$path" ]] || continue
    rm -rfv -- "$path"
  done
done < "$cleanup_list_file"

if [[ $move_artifacts -eq 1 ]]; then
  pdf_files=("$cleanup_directory"/*.pdf)
  if (( ${#pdf_files[@]} )); then
    echo
    echo "Moving all generated artifacts to the root directory."
    echo

    mv -fv -- "${pdf_files[@]}" "$repo_root"/
  fi
fi

shopt -u nullglob

echo
echo "Cleaned up after build."
echo "Done."