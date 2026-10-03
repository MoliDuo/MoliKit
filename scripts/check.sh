#!/usr/bin/env bash
# The check entry (Moli standard 004, 4.2.1): every action file parses, and the workflows lint clean.
set -euo pipefail
cd "$(dirname "$0")/.."

for f in actions/*/action.yml .github/workflows/*.yml .github/dependabot.yml; do
  python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' "$f"
done
docker run --rm -v "$PWD:/repo" -w /repo rhysd/actionlint:1.7.7 -color
echo "check: ok"
