#!/bin/bash

# Get entity group size from env var, default to 1 if not set
ENTITY_GROUP=${ENTITY_GROUP:-1}
# Exit if ENTITY_GROUP is not 1
if [ $ENTITY_GROUP -ne 1 ]; then
  echo "ENTITY_GROUP must be 1"
  exit 1
fi

# Get async job count, default to 1 if not set
ASYNC=${ASYNC:-1}
# Get entity count, default to 5000 if not set
ENTITY_COUNT=${ENTITY_COUNT:-5000}
# Calculate half for each batch (string items and item references)
HALF_COUNT=$((ENTITY_COUNT / 2))

echo "Using async job count: $ASYNC"
echo "Creating $ENTITY_COUNT entities ($HALF_COUNT each type)"

# Function to make a REST API request with retry capability
make_rest_request() {
  local data="$1"
  local response
  local url="http://localhost:818$((1 + RANDOM % $INSTANCES))/rest.php/wikibase/v1/entities/items"
  
  response=$(curl -s -m 20 -X POST -H "Content-Type: application/json" -d "$data" "$url")
  echo "$response" >> process.out
  
  if [[ "$response" != *"item"* ]]; then
    echo "item missing from response, retrying"
    make_rest_request "$data"
  fi
}

# Function to wait until we have less than ASYNC jobs running
wait_for_job_slot() {
  while true; do
    active_jobs=$(jobs -p | wc -l)
    if [ "$active_jobs" -lt "$ASYNC" ]; then
      break
    fi
    sleep 0.1
  done
}

# Create items with string statements
for ((i=1; i<=HALF_COUNT; i++))
do
  wait_for_job_slot
  (
    random_label=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))
    random_desc=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))
    random_alias=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))
    
    # Create REST API payload for string statement
    data="{
      \"item\": {
        \"labels\": {
          \"en\": \"$random_label\"
        },
        \"descriptions\": {
          \"en\": \"$random_desc\"
        },
        \"aliases\": {
          \"en\": [
            \"$random_alias\"
          ]
        },
        \"statements\": {
          \"P4\": [
            {
              \"property\": {
                \"id\": \"P4\"
              },
              \"value\": {
                \"type\": \"value\",
                \"content\": \"statement-string-value\"
              }
            }
          ]
        }
      }
    }"
    
    make_rest_request "$data"
  )&
done

# Create items with item references
for ((i=1; i<=HALF_COUNT; i++))
do
  wait_for_job_slot
  (
    random_label=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))
    random_desc=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))
    random_alias=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))
    
    # Create REST API payload for item reference
    data="{
      \"item\": {
        \"labels\": {
          \"en\": \"$random_label\"
        },
        \"descriptions\": {
          \"en\": \"$random_desc\"
        },
        \"aliases\": {
          \"en\": [
            \"$random_alias\"
          ]
        },
        \"statements\": {
          \"P2\": [
            {
              \"property\": {
                \"id\": \"P2\"
              },
              \"value\": {
                \"type\": \"value\",
                \"content\": \"Q1\"
              }
            }
          ]
        }
      }
    }"
    
    make_rest_request "$data"
  )&
done

wait
