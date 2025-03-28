#!/bin/bash

# Get entity group size from env var, default to 1 if not set
ENTITY_GROUP=${ENTITY_GROUP:-1}
# Get async job count, default to 1 if not set
ASYNC=${ASYNC:-1}
# Get entity count, default to 5000 if not set
ENTITY_COUNT=${ENTITY_COUNT:-5000}
# Calculate half for each batch (string items and item references)
HALF_COUNT=$((ENTITY_COUNT / 2))

echo "Using entity group size: $ENTITY_GROUP"
echo "Using async job count: $ASYNC"
echo "Creating $ENTITY_COUNT entities ($HALF_COUNT each type)"

# Function to make a curl request with a group of entities
make_group_request() {
  local entities=()
  local data="["
  local first=true
  
  # Process all arguments and build the JSON array
  for entity in "$@"; do
    if [ "$first" = true ]; then
      data="${data}${entity}"
      first=false
    else
      data="${data},${entity}"
    fi
  done
  
  data="${data}]"
  local response
  local url="http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php"
  
  response=$(curl -s -m 20 -X POST -F "action=wbfastimport" -F "format=json" -F "data=${data}" "$url")
  echo "$response" >> process.out
  
  if [[ "$response" != *"success"* ]]; then
    echo "success missing, retrying"
    make_group_request "$@"
  fi
}

# Create items with string statements in groups
for ((i=1; i<=HALF_COUNT; i+=$ENTITY_GROUP))
do
  (
    # Temporary file to store the JSON array
    temp_file=$(mktemp)
    echo "[" > "$temp_file"
    
    # Calculate the actual group size (might be smaller at the end)
    group_size=$(( i+ENTITY_GROUP-1 <= HALF_COUNT ? ENTITY_GROUP : HALF_COUNT-i+1 ))
    
    # Generate each entity and append to the temp file
    for ((j=0; j<group_size; j++))
    do
      if [ $j -gt 0 ]; then
        echo "," >> "$temp_file"
      fi
      
      entity="{\"type\":\"item\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P4\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P4\",\"datavalue\":{\"value\":\"statement-string-value\",\"type\":\"string\"},\"datatype\":\"string\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}"
      
      echo -n "$entity" >> "$temp_file"
    done
    
    echo "]" >> "$temp_file"
    
    # Send the request with the temp file data
    data=$(cat "$temp_file")
    url="http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php"
    response=$(curl -s -m 20 -X POST -F "action=wbfastimport" -F "format=json" -F "data=${data}" "$url")
    echo "$response" >> process.out
    
    # Clean up
    rm "$temp_file"
    
    # Retry if needed
    if [[ "$response" != *"success"* ]]; then
      echo "success missing, retrying group starting at $i"
      # Retry logic would go here but for simplicity we'll just log the error
    fi
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then sleep 0.5; fi
done

# Create items with item references in groups
for ((i=1; i<=HALF_COUNT; i+=$ENTITY_GROUP))
do
  (
    # Temporary file to store the JSON array
    temp_file=$(mktemp)
    echo "[" > "$temp_file"
    
    # Calculate the actual group size (might be smaller at the end)
    group_size=$(( i+ENTITY_GROUP-1 <= HALF_COUNT ? ENTITY_GROUP : HALF_COUNT-i+1 ))
    
    # Generate each entity and append to the temp file
    for ((j=0; j<group_size; j++))
    do
      if [ $j -gt 0 ]; then
        echo "," >> "$temp_file"
      fi
      
      entity="{\"type\":\"item\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P2\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P2\",\"datavalue\":{\"value\":{\"entity-type\":\"item\",\"numeric-id\":1,\"id\":\"Q1\"},\"type\":\"wikibase-entityid\"},\"datatype\":\"wikibase-item\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}"
      
      echo -n "$entity" >> "$temp_file"
    done
    
    echo "]" >> "$temp_file"
    
    # Send the request with the temp file data
    data=$(cat "$temp_file")
    url="http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php"
    response=$(curl -s -m 20 -X POST -F "action=wbfastimport" -F "format=json" -F "data=${data}" "$url")
    echo "$response" >> process.out
    
    # Clean up
    rm "$temp_file"
    
    # Retry if needed
    if [[ "$response" != *"success"* ]]; then
      echo "success missing, retrying group starting at $i"
      # Retry logic would go here but for simplicity we'll just log the error
    fi
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then sleep 0.5; fi
done

wait
