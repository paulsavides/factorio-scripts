#!/bin/bash
source_root=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))

function help() {
  echo "usage: factorio-scripts \$arg"
  echo -e "\t help <print this message and exit>"
  echo -e "\t provision <initial provision of factorio install>"
  echo -e "\t restart <restart factorio service>"
  echo -e "\t update <update factorio install in place>"
}

if [ "$#" -ne 1 ]; then
  echo "Expected single argument but received [${@}]"
  help
  exit 1
fi

if [ "$1" == "help" ]; then
  help
  exit 0
elif [ "$1" == "provision" ]; then
  sudo ${source_root}/scripts/initial-provision.sh
elif [ "$1" == "restart" ]; then
  sudo ${source_root}/scripts/restart-service.sh
elif [ "$1" == "update" ]; then
  sudo ${source_root}/scripts/update-in-place.sh
else
  echo "Unexpected argument $1"
  help
  exit 1
fi
