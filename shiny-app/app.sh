#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
R -e "shiny::runApp('$SCRIPT_DIR', port=8888, host='0.0.0.0')"
