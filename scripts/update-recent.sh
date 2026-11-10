#!/usr/bin/env bash
# Atualiza a seção "Mexendo agora" do README com os 3 repositórios públicos
# (não arquivados) com push mais recente. Requer GH_TOKEN e OWNER.
set -euo pipefail

rows=$(gh repo list "$OWNER" --visibility public --no-archived --limit 100 \
  --json name,description,pushedAt,url \
  --jq "map(select(.name != \"$OWNER\")) | sort_by(.pushedAt) | reverse | .[:3][]
        | \"- \`\(.pushedAt[:10])\` [**\(.name)**](\(.url)) — \(.description // \"sem descrição\")\"")

block=$(printf '<!--RECENT:START-->\n%s\n<!--RECENT:END-->' "$rows")

awk -v block="$block" '
  /<!--RECENT:START-->/ { print block; skip = 1; next }
  /<!--RECENT:END-->/   { skip = 0; next }
  !skip
' README.md > README.tmp && mv README.tmp README.md
