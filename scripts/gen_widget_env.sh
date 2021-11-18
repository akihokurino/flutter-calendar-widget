#!/usr/bin/env bash

set -eu

APP_ROOT=$(dirname $0)/..
cd ${APP_ROOT}

source .env
export $(cut -d= -f1 .env)

envsubst < ios/Widget/Env.template > ios/Widget/Env.swift