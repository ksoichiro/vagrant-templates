#!/usr/bin/env bash

CURRENT=$(cd $(dirname $0) && pwd)
source ~vagrant/android-common.sh

function create_project() {
  local app_name=$1
  local package=$2
  local activity=$3
  if [ ! -d ${APPS_DIR}/${app_name} ]; then
    echo "Creating app ${app_name}..."
    mkdir -p ${APPS_DIR}/${app_name}
    pushd ${APPS_DIR}/${app_name} > /dev/null 2>&1
    android create project -g -v 0.9.+ -a ${activity} -k ${package} -t android-17 -p . > /dev/null 2>&1
    popd > /dev/null 2>&1
  fi
}

create_project example com.example.Example MainActivity
