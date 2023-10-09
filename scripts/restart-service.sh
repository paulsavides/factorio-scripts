#!/bin/bash

source_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

sytemctl stop factorio
systemctl daemon-reload
systemctl reenable $source_root/../unit/factorio.service
systemctl start factorio
systemctl status factorio
