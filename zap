#!/bin/bash

set -e

function usage()
{
  echo "Usage: zap [-s] [appname]"
  exit 1
}

function remove()
{
  echo "$cmd -ri $1"
}

if [[ $# -lt 1 ]]; then
  usage
fi

cmd="rm"
plist="/usr/libexec/PlistBuddy"
info_plist="/Contents/Info.plist"
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

plist_path="${app%/}$info_plist"
if [[ ! -f $plist_path ]]; then
  echo "No plist at $plist_path"
  exit 1
fi

identifier=$($plist -c "print :CFBundleIdentifier" "$plist_path")
remove "$app"
