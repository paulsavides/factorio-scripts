#!/bin/bash

source_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$source_root/common/shared"

tmp_dir_base=/tmp/factorio-tmp
factorio_root=/opt/factorio
install_url=https://www.factorio.com/get-download/latest/headless/linux64

function download_latest_version() {
  download_location=$1
  download_url=$2
  filename=$3

  if [ ! -d $download_location ]; then
    log "creating directory $download_location"
    mkdir $download_location
  else
    log "purging download directory $download_location"
    rm -rf $download_location/*
  fi

  latest_fq=$download_location/$filename

  log "downloading latest factorio version to $latest_fq"
  wget $download_url -O $download_location/$filename || return $?
}

function backup_required_files() {
  tmp_dir=$1

  if [ -d $tmp_dir ]; then
    log_err "did not expect $tmp_dir to already exist... exiting"
    return 1
  else
    log "creating directory $tmp_dir"
    mkdir $tmp_dir
  fi

  cp_directories=(
    "saves"
    "mods"
  )

  cp_files=(
    "achievements.dat"
    "config-path.cfg"
    "player-data.json"
    "config/config.ini"
    "data/map-gen-settings.json"
    "data/map-settings.json"
    "data/server-adminlist.json"
    "data/server-settings.json"
    "data/server-whitelist.json"
  )

  for cp_dir in ${cp_directories[@]}; do
    cp_dir_fq=$factorio_root/$cp_dir
    if [ -d $cp_dir_fq ]; then
      log "copying directory $cp_dir_fq"

      mkdir $tmp_dir/$cp_dir
      cp $cp_dir_fq/* $tmp_dir/$cp_dir
    fi
  done

  for cp_file in ${cp_files[@]}; do
    cp_file_fq=$factorio_root/$cp_file
    if [ -f $cp_file_fq ]; then
      cp_file_dir=$(dirname $cp_file)
      if [ "." != "$cp_file_dir" ] && [ ! -d "$tmp_dir/$cp_file_dir" ]; then
        log "creating directory prefix $tmp_dir/$cp_file_dir"
        mkdir $tmp_dir/$cp_file_dir
      fi

      log "copying file $cp_file_fq"
      cp $cp_file_fq $tmp_dir/$cp_file
    fi
  done
}

function main() {
  rand_ext=$RANDOM
  backup_location=$tmp_dir_base/$rand_ext
  download_location=$tmp_dir_base/downloads

  service_running=$(systemctl is-active --quiet factorio && echo "true")

  if [ "true" = "$service_running" ]; then
    log "Stopping currently running factorio service..."
    systemctl stop factorio
    log "Factorio stopped"
    systemctl status factorio
  fi

  log "using tmp_dir_base=$tmp_dir_base"
  log "using backup_location=$backup_location"
  log "using download_location=$download_location"
  log "using factorio_root=$factorio_root"

  if [ ! -d $tmp_dir_base ]; then
    log "creating directory $tmp_dir_base"
    mkdir $tmp_dir_base
  fi

  if [ ! -d $factorio_root ]; then
    log "creating directory $factorio_root"
    mkdir $factorio_root
  fi

  log "backing up files that need to be persisted across installs..."
  backup_required_files $backup_location || return $?

  filename=factorio_latest

  log "downloading latest version..."
  download_latest_version $download_location $install_url $filename || return $?

  log "purging current installation..."
  rm -rf $factorio_root/* || return $?

  log "extracting downloaded file over expected directory"
  tar --strip-components 1 -xf "$download_location/$filename" -C $factorio_root || return $?

  if [ -z "$(ls -A $backup_location)" ]; then
    log "no files backed up, skipping restore"
  else
    log "restoring backed up files to new install..."
    cp -rf $backup_location/* $factorio_root || return $?
  fi

  log "reassigning ownership of all files to factorio user..."
  chown -R factorio:factorio $factorio_root/* || return $?

  if [ "true" = "$service_running" ]; then
    log "restarting factorio service..."
    systemctl start factorio
    systemctl status factorio
  fi

  log "installation finished, purge $tmp_dir_base manually once you are satisfied it worked"
}

main

if [ $? -ne 0 ]; then
  log_err "an error ocurred in the installation, any data should be preserved in $tmp_dir_base"
  exit 1
else
  exit 0
fi
