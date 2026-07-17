#!/usr/bin/env bash
# Domino App entrypoint.
# Domino executes this script to launch a published App.
# It must bind to 0.0.0.0:8888 (handled inside app.py).

set -e

python app.py
