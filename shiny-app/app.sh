#!/usr/bin/env bash
# Domino App entrypoint for the Shiny dashboard.
# Apps in Domino must run with host = "0.0.0.0". Port 8888 matches the
# convention used by the Dash app in this same project.

set -e

R -e 'shiny::runApp("./", port=8888, host="0.0.0.0")'
