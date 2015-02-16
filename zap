#!/bin/bash

set -e
set -o pipefail

function usage()
{
  echo "Usage: zap [-s] [appname]"
  exit 1
}

function remove()
{
  paths=("$@")
  for path in "${paths[@]}"
  do
    if [[ -e $path ]]; then
      read -p "Remove $path? " -r
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        $cmd -r $path
      fi
    fi
  done
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

app="$1"
if [[ ! -d $app ]]; then
  app="/Applications/${app%.app}.app"

  if [[ ! -d $app ]]; then
    echo "Application path must be absolute or be in /Applications"
    exit 1
  fi
fi

if [[ ! -w $app ]]; then
  echo "$app cannot be deleted. Try running this again with 'sudo'"
  exit 1
fi

plist_path="${app%/}$info_plist"
if [[ ! -f $plist_path ]]; then
  echo "No plist at $plist_path"
  exit 1
fi

identifier=$($plist -c 'print :CFBundleIdentifier' "$plist_path")
if [[ -z "$identifier" ]]; then
  echo "Couldn't determine bundle identifier '$identifier'"
  exit 1
fi

appname=$(basename "${app%.*}")
pkill -f "$app" || true
lines=$(pgrep -f "$(echo "$app" | sed -E 's/(.)/[\1]/')" | wc -l | xargs || true)
if [[ $lines -gt 0 ]]; then
  echo "Please quit $appname and try again"
  exit 1
fi

remove "$app"
remove "$HOME/Library/Application Support/$appname"
remove "$HOME/Library/Application Support/$identifier"
remove "$HOME/Library/Containers/$identifier"
remove "$HOME/Library/Caches/$appname"
remove "$HOME/Library/Caches/$identifier"
remove "$HOME/Library/$appname"
remove "$HOME/Library/Preferences/"*"$identifier"*".plist"
remove "$HOME/Library/Saved Application State/$identifier.savedState"
remove "$HOME/Library/SyncedPreferences/$identifier"*".plist"
remove "$HOME/Library/WebKit/$identifier"
