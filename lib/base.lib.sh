#!/bin/bash

if [ -z "${SUPP_BASE_LIB_SH}" ]
then

SUPP_BASE_LIB_SH="loaded"

[ -n "${PRODUCTION_ENVIRONMENT}" ] || PRODUCTION_ENVIRONMENT="production"

SUPP_DIR=$(dirname "$(realpath -s "$(dirname "${BASH_SOURCE[0]}")")")
APP_DIR=$(dirname "${SUPP_DIR}")
START_DIR=$(pwd)

SAIL_BIN="${APP_DIR}/sail/sail"


function supError() {
  local msgPrefix="support-lib"
  if [ $# -gt 1 ]
  then
    msgPrefix="${msgPrefix} | $1"
    shift
  fi
  echo ""
  echo "${msgPrefix} | ERROR | $@"
  echo ""
  exit 1
}


function supWarn() {
  local msgPrefix="support-lib"
  if [ $# -gt 1 ]
  then
    msgPrefix="${msgPrefix} | $1"
    shift
  fi
  echo "${msgPrefix} | WARN | $@"
}


function supAbortIfProduction() {
  [ "${SERVER_ENVIRONMENT}" != "${PRODUCTION_ENVIRONMENT}" ] || supError "Aborted in production environment"
}


function supSourceFile() {
  local zFile="$1"

  [ ! -f "${zFile}" ] && supError "supSourceFile" "File not found: ${zFile}"
  source "${zFile}"
  if [ $? -ne 0 ]
  then
    supError "supSourceFile" "Fail to source file: ${zFile}"
  fi
}


function supSourceFileIfExists() {
  local zFile="$1"

  if [ -f "${zFile}" ]
  then
    supSourceFile "$@"
  fi
}


function supInDocker() {
  cat /proc/mounts | grep '^overlay / overlay ' | grep --quiet '/docker/overlay2/'
  return $?
}


function supNodejsExec () {
  supInDocker
  if [ $? -eq 0 ]
  then
    /bin/bash -i -c "$@"
  else
    "${SAIL_BIN}" exec nodejs /bin/bash -i -c "$@"
  fi
}


function pm2_hasService () {
  local zService="$1" && shift
  [ -n "${zService}" ] || supError "pm2_hasService" "Parameter not supplied: service"

  supNodejsExec "pm2 -m list | grep --quiet '^+--- ${zService}$'"
  return $?
}


supSourceFileIfExists "${SUPP_DIR}/.env"

fi
