#!/bin/bash

source_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$source_root/common/shared"

log "creating factorio user..."
useradd factorio

log "creating /opt/factorio"
mkdir /opt/factorio

log "setting factorio user as owner of /opt/factorio"
chown -R factorio:factorio /opt/factorio

log "running update in place script to download factorio..."
/bin/bash $source_root/update-in-place.sh

log "creating initial save"
su factorio -c "/opt/factorio/bin/x64/factorio --create /opt/factorio/saves/default.zip"

systemctl enable $source_root/unit/factorio.service
systemctl status $source_root/unit/factorio.service


