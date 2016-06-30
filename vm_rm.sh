#!/usr/bin/env bash

#
# This script will setup your environment to run docker.  It sets the proper
# environment variables.
#
# Usage: ./vm_rm.sh
#

set +e

current_folder=$(pwd)
project_name=$(basename $current_folder)

docker-machine active &>/dev/null

if [ $? == 0 ]; then
  echo "Stopping containers for project ${project_name}..."
  docker-compose stop
fi

vm_state=$(docker-machine ls --filter Name=$project_name -f "{{.Name}} {{.State}}" | cut -d' ' -f2)
if [ -n "$vm_state" ] && [ "$vm_state" != "Stopped" ]; then
  echo "Stopping vm for project ${project_name}..."
  docker-machine stop $project_name
fi

echo "Removing vm for project ${project_name}..."
docker-machine rm -f $project_name
