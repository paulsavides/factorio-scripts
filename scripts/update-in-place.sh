#!/bin/bash

tmp_dir=/tmp/factorio-tmp
factorio_root=/opt/factorio

function log() {
  echo "INF: $*"
}

function main() {
  log "using tmp_dir=$tmp_dir"
  log "using factorio_root=$factorio_root"

  if [ -d $tmp_dir ]; then
    log "creating directory $tmp_dir"
    rm -rf $tmp_dir
  else
    log "purging directory $tmp_dir"
    mkdir $tmp_dir
  fi

  cp_directories=(
    "saves"
    "mods"
  )

  cp_files=(
    "achievements.dat"
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
      log "copying file $cp_file_fq"

      cp_file_dir=$(dirname $cp_file)
      if [ "." -ne "$cp_file_dir" ]; then
        log "creating file prefix $tmp_dir/$cp_file_dir"
        mkdir $tmp_dir/$cp_file_dir
      fi

      cp $cp_file_fq $tmp_dir/$cp_file
    fi
  done
}

main
exit $?
