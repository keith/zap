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
        $cmd -r "$path"
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
app_path="$app"
if [[ ! -d $app_path ]]; then
  app_path="/Applications/${app%.app}.app"

  if [[ ! -d $app_path ]]; then
    app_path="$HOME/Applications/${app%.app}.app"
  fi

  if [[ ! -d $app_path ]]; then
    echo "Application path must be absolute or in /Applications or $HOME/Applications"
    exit 1
  fi
fi

if [[ ! -w $app_path ]]; then
  echo "$app_path cannot be deleted. Try running this again with 'sudo'"
  exit 1
fi

plist_path="${app_path%/}$info_plist"
if [[ ! -f $plist_path ]]; then
  echo "No plist at $plist_path"
  exit 1
fi

identifier=$($plist -c 'print :CFBundleIdentifier' "$plist_path")
if [[ -z "$identifier" ]]; then
  echo "Couldn't determine bundle identifier '$identifier'"
  exit 1
fi

appname=$(basename "${app_path%.*}")
pkill -f "$app_path" || true
lines=$(pgrep -f "$(echo "$app_path" | sed -E 's/(.)/[\1]/')" | wc -l | xargs || true)
if [[ $lines -gt 0 ]]; then
  echo "Please quit $appname and try again"
  exit 1
fi

remove "$app_path"
remove "$HOME/Library/Application Support/$appname"
remove "$HOME/Library/Application Support/$identifier"
remove "$HOME/Library/Containers/$identifier"*
remove "$HOME/Library/Caches/$appname"
remove "$HOME/Library/Caches/$identifier"
remove "$HOME/Library/$appname"
remove "$HOME/Library/Preferences/"*"$identifier"*".plist"
remove "$HOME/Library/Saved Application State/$identifier.savedState"
remove "$HOME/Library/SyncedPreferences/$identifier"*".plist"
remove "$HOME/Library/WebKit/$identifier"
