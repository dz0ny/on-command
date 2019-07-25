#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2002,SC2034,SC1090,SC2154

# skip if not a new comment
if [[ "$(jq -r ".action" "$GITHUB_EVENT_PATH")" != "created" ]]; then
	echo "This is not a new comment event!"
	exit 78
fi

COMMENT=$(jq -r ".comment.body" "$GITHUB_EVENT_PATH")

echo "Checking if '$COMMENT' contains '$1' command..."
if [[ "$COMMENT" =~ ^$1 ]]; then
  ARGS=$(echo "$COMMENT" | cut -d "\"" -f2 | cut -d "\"" -f1 | sed -e "s#^/$1 ##")
  echo "Passing arguments '$ARGS'"
  echo "$ARGS" > $GITHUB_WORKSPACE/.github/$1-args
else
  echo "Skippping, command not found in comment."
  exit 78
fi
