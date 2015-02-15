#!/bin/bash

set -e

function usage()
{
  echo "Usage: zap [-s] [appname]"
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

cmd="rm"
if [[ $1 == "-s" ]]; then
  cmd="srm"
  shift
elif [[ $# -gt 1 ]]; then
  usage
fi

app=$1
if [[ ! -d $app ]]; then
  app="/Applications/${app%.app}.app"

  if [[ ! -d $app ]]; then
    echo "Application path must be absolute or be in /Applications"
    exit 1
  fi
fi
