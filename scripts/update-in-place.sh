#!/bin/bash
script_source=$(dirname ${BASH_SOURCE[0]})
. $script_source/logging.sh

tmp_dir=/tmp/factorio-tmp
factorio_root=/opt/factorio

function main() {
  if [ -d $tmp_dir ]; then
    rm -rf $tmp_dir
  elif
    mkdir $tmp_dir
  fi

  mkdir $tmp_dir/saves
  mkdir $tmp_dir/config
  mkdir $tmp_dir/data

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
      mkdir $tmp_dir/$cp_dir
      cp $cp_dir_fq/* $tmp_dir/$cp_dir
    fi
  done

  for cp_file in ${cp_files[@]}; do
    cp_file_fq=$factorio_root/$cp_file
    if [ -f $cp_file_fq ]; then
      cp_file_dir=$(dirname $cp_file)
      if [ "." -ne "$cp_file_dir"]; then
        mkdir $tmp_dir/$cp_file_dir
      fi

      cp $cp_file_fq $tmp_dir/$cp_file
    fi
  done
}

main
exit $?
