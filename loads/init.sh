#!/bin/bash

# Single entity request for initialization
make_single_request() {
  local response
  local url="http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php"
  response=$(curl -s -m 20 -X POST -F "action=wbfastimport" -F "format=json" -F "data=[$1]" "$url")
  echo "$response" >> process.out
  if [[ "$response" != *"success"* ]]; then
    echo "success missing, retrying"
    make_single_request "$1"
  fi
}

make_request() {
  local response
  local url="http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php"
  response=$(curl -s -m 20 -X POST -F "action=wbeditentity" -F "format=json" -F "token=+\\" -F "$1" -F "$2" "$url")
  echo "$response" >> process.out
  if [[ "$response" != *"success"* ]]; then
    echo "success missing, retrying"
    make_request "$1" "$2"
  fi
}

# Get the ball rolling with a simple entity
make_single_request "{\"type\":\"item\"}"
# make_request "new=property" "data={\"datatype\":\"string\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}"

# For properties, we need to use wbeditentity as wbfastimport doesn't seem to handle property creation
# P1
(echo $(curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=property' -F "data={\"datatype\":\"string\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php)) >> process.out

# Create some properties
# P2 = wikibase-item
# P3 = wikibase-property
# P4 = string
# P5 = time
properties=( wikibase-item wikibase-property string time )
for p in "${properties[@]}"
do
  (echo $(curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=property' -F "data={\"datatype\":\"${p}\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php)) >> process.out
done