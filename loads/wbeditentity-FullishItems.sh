# Function to make a curl request and retry if "success" is missing
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

ENTITY_GROUP=${ENTITY_GROUP:-1}
# die if it isnt 1
if [ $ENTITY_GROUP -ne 1 ]; then
  echo "ENTITY_GROUP must be 1"
  exit 1
fi

# Get async job count, default to 1 if not set
ASYNC=${ASYNC:-1}
# Get entity count, default to 2000 if not set
ENTITY_COUNT=${ENTITY_COUNT:-2000}
# Calculate half for each batch (string items and item references)
HALF_COUNT=$((ENTITY_COUNT / 2))

echo "Using async job count: $ASYNC"
echo "Creating $ENTITY_COUNT entities ($HALF_COUNT each type)"

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

# Create some items including statements

# Half with strings
for i in $(seq 1 $HALF_COUNT)
do
  wait_for_job_slot
  (
    make_request "new=item" "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P4\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P4\",\"datavalue\":{\"value\":\"statement-string-value\",\"type\":\"string\"},\"datatype\":\"string\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}"
  )&
done

# Half linking to other items
for i in $(seq 1 $HALF_COUNT)
do
  wait_for_job_slot
  (
    make_request "new=item" "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P2\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P2\",\"datavalue\":{\"value\":{\"entity-type\":\"item\",\"numeric-id\":1,\"id\":\"Q1\"},\"type\":\"wikibase-entityid\"},\"datatype\":\"wikibase-item\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}"
  )&
done

wait