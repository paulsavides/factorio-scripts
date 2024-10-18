#!/bin/bash

source_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

echo "linking $source_root/factorio-scripts.sh to /usr/local/bin/factorio-scripts"
if sudo test -L "/usr/local/bin/factorio-scripts"; then
  sudo rm /usr/local/bin/factorio-scripts
fi

sudo ln -s "$source_root/factorio-scripts.sh" "/usr/local/bin/factorio-scripts"
echo "done, run the following for help"
echo -e "\tfactorio-scripts help"
