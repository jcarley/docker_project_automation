#!/usr/bin/env bash

#
# This script will setup your environment to run docker.  It sets the proper
# environment variables.
#
# Usage: ./vm_stop.sh
#

set +e

current_folder=$(pwd)
project_name=$(basename $current_folder)

docker-compose stop
docker-machine stop $project_name

