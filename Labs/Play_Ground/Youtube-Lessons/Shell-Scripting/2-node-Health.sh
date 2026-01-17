#!/bin/bash

########################################
# Author: Ganil
# Date: 01/16/26
#
# This script outputs the node health
#
# Version: v1
#######################################

set -x # debug mode

df -h


free -g


nproc


ps -ef
