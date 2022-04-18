#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

my_ip=$(curl -qs http://ifconfig.ru/)
jq -n --arg my_ip "$my_ip" '{"my_ip":"'$my_ip'"}'
