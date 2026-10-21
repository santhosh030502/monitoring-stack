#!/usr/bin/env bash
# Reload prometheus and alertmanager config without restarting containers.
set -euo pipefail

curl -s -X POST localhost:9090/-/reload && echo "prometheus reloaded"
curl -s -X POST localhost:9093/-/reload && echo "alertmanager reloaded"
