#!/usr/bin/env bash
# ship-it-script — tiny deploy orchestrator
set -euo pipefail

ENV="${1:-}"
DRY=0
[[ "${2:-}" == "--dry-run" ]] && DRY=1

usage() {
  echo "usage: $0 <dev|staging|prod> [--dry-run]"
  exit 1
}

[[ -z "$ENV" ]] && usage
[[ -f "env/${ENV}.env" ]] || { echo "missing env/${ENV}.env"; exit 1; }
# shellcheck disable=SC1090
source "env/${ENV}.env"

run() {
  if [[ "$DRY" -eq 1 ]]; then
    echo "DRY: $*"
  else
    echo "+ $*"
    eval "$@"
  fi
}

ts="$(date +%Y%m%d%H%M%S)"
release_dir="releases/${ENV}/${ts}"

echo "== shipping ${APP_NAME} to ${ENV} =="
run "mkdir -p '${release_dir}'"
run "echo '${ts}' > '${release_dir}/VERSION'"
run "echo deploy user=${DEPLOY_USER} host=${DEPLOY_HOST}"
run "echo 'rsync -az ./ ${DEPLOY_USER}@${DEPLOY_HOST}:${APP_PATH}/'"
run "echo 'ssh ${DEPLOY_USER}@${DEPLOY_HOST} systemctl restart ${APP_NAME}'"
run "ln -sfn '${release_dir}' 'releases/${ENV}/current'"
echo "done."
