#!/usr/bin/env bash
# First time setup: creates the local secret files that are not in git.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f alertmanager/secrets/slack_webhook ]; then
  cp alertmanager/secrets/slack_webhook.example alertmanager/secrets/slack_webhook
  echo "created alertmanager/secrets/slack_webhook"
  echo "put your real slack webhook url in it to get alerts in slack"
fi

if [ ! -f .env ]; then
  cp .env.example .env
  echo "created .env (change the grafana password)"
fi

echo "setup done. run: docker compose up -d"
