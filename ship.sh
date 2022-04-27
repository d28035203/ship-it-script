#!/usr/bin/env bash
# ship-it-script — env-aware deploy helper with dry-run and release dirs
set -euo pipefail

ENV_NAME="${1:-}"
DRY=0
[[ "${2:-}" == "--dry-run" ]] && DRY=1

usage() {
  echo "usage: $0 <dev|staging|prod> [--dry-run]" >&2
  exit 1
}

[[ -n "$ENV_NAME" ]] || usage
[[ -f "env/${ENV_NAME}.env" ]] || { echo "missing env/${ENV_NAME}.env" >&2; exit 1; }

# shellcheck disable=SC1090
source "env/${ENV_NAME}.env"

: "${APP_NAME:?}"
: "${DEPLOY_USER:?}"
: "${DEPLOY_HOST:?}"
: "${APP_PATH:?}"

run() {
  if [[ "$DRY" -eq 1 ]]; then
    printf 'DRY  %s\n' "$*"
  else
    printf '+ %s\n' "$*"
    # shellcheck disable=SC2086
    eval "$@"
  fi
}

ts="$(date +%Y%m%d%H%M%S)"
release_dir="releases/${ENV_NAME}/${ts}"
mkdir -p "releases/${ENV_NAME}"

echo "== shipping ${APP_NAME} → ${ENV_NAME} (${DEPLOY_USER}@${DEPLOY_HOST}) =="

run "mkdir -p '${release_dir}'"
run "printf '%s\n' '${ts}' > '${release_dir}/VERSION'"
run "printf '%s\n' '${ENV_NAME}' > '${release_dir}/ENV'"

# Simulated remote steps — replace with real rsync/ssh when you have hosts
run "printf 'rsync -az --delete ./ %s@%s:%s/releases/%s/\n' '${DEPLOY_USER}' '${DEPLOY_HOST}' '${APP_PATH}' '${ts}'"
run "printf 'ssh %s@%s \"ln -sfn %s/releases/%s %s/current && systemctl restart %s\"\n' \
  '${DEPLOY_USER}' '${DEPLOY_HOST}' '${APP_PATH}' '${ts}' '${APP_PATH}' '${APP_NAME}'"

run "ln -sfn '${release_dir}' 'releases/${ENV_NAME}/current'"
echo "release recorded at ${release_dir}"
echo "done."
