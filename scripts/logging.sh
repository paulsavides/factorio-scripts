#!/bin/bash

function debug() {
  if [ "${DEBUG-0}" -gt 0 ]; then
    echo "DEBUG: $*"
  fi
}

function error() {
  echo "$*" 1>&2
}

function info() {
  echo "$*"
}
