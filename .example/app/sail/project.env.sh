#!/bin/bash

if [ -z "${PROJECT_ENV_SH}" ]
then

PROJECT_ENV_SH="loaded"

[ -z "${NODEJS_USERNAME}" ] && sailError "NODEJS_USERNAME não definido"
[ -z "${NODEJS_USERID}" ] && sailError "NODEJS_USERID não definido"
[ -z "${NODEJS_VERSION}" ] && sailError "NODEJS_VERSION não definido"
[ -z "${NODEJS_CODENAME}" ] && sailError "NODEJS_CODENAME não definido"
[ -z "${NODEJS_PORT}" ] && sailError "NODEJS_PORT não definido"

export NODEJS_USERNAME
export NODEJS_USERID
export NODEJS_VERSION
export NODEJS_CODENAME
export NODEJS_PORT

export SAIL_SERVICE_NODEJS="${COMPOSE_PROJECT_NAME}-nodejs"
export SAIL_SERVICE_NODEJS_USER="${NODEJS_USERNAME}"

fi
