#!/bin/bash
set -euo pipefail

readonly ARGS=${1:--a}

uname "${1}"
