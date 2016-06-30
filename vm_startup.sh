#!/usr/bin/env bash

#
# This script will setup your environment to run docker.  It sets the proper
# environment variables.
#
# Usage: source ./vm_startup.sh
#

set +e

current_folder=$(pwd)
project_name=$(basename $current_folder)

docker-machine status $project_name &>/dev/null

if [ $? != 0 ]; then
  echo "# A docker host vm not found."
  echo "# Creating vm and waiting for it to come online..."
  if command -v VBoxManage >/dev/null; then
    docker-machine create --driver virtualbox $project_name &>/dev/null
  else
    docker-machine create --driver vmwarefusion $project_name &>/dev/null
  fi
fi

if test $(docker-machine status $project_name) == "Stopped"; then
  echo "# Not running vm for project ${project_name}... starting up now."
  docker-machine start $project_name >/dev/null
fi

echo "# Running the \`docker-machine env\` command."
eval "$(docker-machine env $project_name)"

docker_machine_ip=$(docker-machine ip $project_name)
export DOCKER_MACHINE_IP=$docker_machine_ip

echo "# Machine is online.  Starting up docker containers for $project_name environment."
echo "# Please be patient, this may take awhile."
# docker-compose up -d &>/dev/null
docker-compose up -d

echo "# The docker host ip is: "
echo "#   $DOCKER_MACHINE_IP"
echo
echo

echo "Docker containers currently running"
docker ps --format "{{.ID}}: {{.Image}} => {{.Status}}"

echo
echo

echo "# You are all set."
echo
