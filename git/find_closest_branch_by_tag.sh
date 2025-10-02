#!/bin/bash
TAG="$1"
if [ -z "$TAG" ]; then
  echo "Usage: $0 <tag_name>"
  exit 1
fi

# Lister les branches contenant le tag
echo "Branches contenant le tag $TAG :"
git branch --contains "$TAG"

# Trouver la branche parente approximative
echo "Branche parente approximative :"
git show-branch -a | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed -E 's/.*\[(.*)\].*/\1/' | cut -d'~' -f1