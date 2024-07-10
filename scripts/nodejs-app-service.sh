#!/bin/bash

_bootstrap="$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")/.bootstrap.sh"
while [ ! -f "${_bootstrap}" ]; do
  _bootstrap="$(dirname "$(dirname "${_bootstrap}")")/$(basename "${_bootstrap}")"; [ -f "${_bootstrap}" ] && break
  [ "$(dirname "${_bootstrap}")" != "/" ] || { echo -e "\n${BASH_SOURCE[0]} | File .bootstrap.sh not found\n"; exit 1; }
done
source "${_bootstrap}" || { echo -e "\n${BASH_SOURCE[0]} | Fail to source file: ${_bootstrap}\n"; exit 1; }

[ -n "${APP_SERVICE_NAME}" ] || supError "APP_SERVICE_NAME not defined"
[ -n "${APP_SERVICE_START}" ] || supError "APP_SERVICE_START not defined"

#-- init parameters
pAction=""
#-- help message
msgHelp="
Use: $(basename $0) <action> [options]

action:
  start  Start app service
  stop   Stop app service
  logs   Show app service logs

options:
   --help  Show this help
"
#-- get parameters
while [ $# -gt 0 ]
do
  case "$1" in
    "--help" | "help" )
       echo "${msgHelp}"
       exit 0;
    ;;
    *)
      [ -z "${pAction}" ] || supError "Invalid parameter: $1"
      [[ ",start,stop,logs," == *",$1,"* ]] || supError "Invalid action: $1"
      pAction="$1"
    ;;
  esac
  [ $# -gt 0 ] && shift 1
done

[ -z "${pAction}" ] && supError "Parameter not supplied: action"

case "${pAction}" in
  "start")
    if pm2_hasService "${APP_SERVICE_NAME}"
    then
      supWarn "Service '${APP_SERVICE_NAME}' already running"
    else
      if [ ! -d "${APP_SERVICE_DIR}/node_modules" ]
      then
        "${SUPP_DIR}/nodejs-npm-install.sh"
        [ $? -eq 0 ] || supError "Fail running <npm install>"
      fi
      supNodejsExec "pm2 -m start --name '${APP_SERVICE_NAME}' '${APP_SERVICE_START}'"
    fi
  ;;
  "stop")
    if pm2_hasService "${APP_SERVICE_NAME}"
    then
      supNodejsExec "pm2 -m delete '${APP_SERVICE_NAME}'"
    else
      supWarn "Service '${APP_SERVICE_NAME}' is not running"
    fi
  ;;
  "logs")
    if pm2_hasService "${APP_SERVICE_NAME}"
    then
      supNodejsExec "pm2 logs '${APP_SERVICE_NAME}'"
    else
      supWarn "Service '${APP_SERVICE_NAME}' is not running"
    fi
  ;;
esac
