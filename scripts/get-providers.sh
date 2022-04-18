#!/bin/bash

LIST='providers.csv'

BASE_URL='https://api.github.com/repos/'
HEADER='Accept: application/vnd.github.v3+json'

while read -r line ; do
  F1=$(echo ${line} | awk -F ',' '{print $1}')
  F2=$(echo ${line} | awk -F ',' '{print $2}')
  F3=$(echo ${line} | awk -F ',' '{print $3}')

  PROV_URL=$(echo "${BASE_URL}/${F3}/tags" | tr -s '/')

  # Get 11 available versions and keep them in reverse order
  versions=$(curl -sH "${HEADER}" "${PROV_URL}" | jq -r '.[].name' | head -11 |tac )
  
  mkdir -p /tmp/tf/
  for ver in $versions ; do 
    ver=$(echo $ver | sed 's/^v//' )
    cat << EOT > /tmp/tf/main.tf
    terraform {
      required_providers {
        ${F1} = {
          source = "$F2"
          version = "${ver}"
        }
      }
    }
EOT
    terraform init -upgrade
  done

done < ${LIST}
