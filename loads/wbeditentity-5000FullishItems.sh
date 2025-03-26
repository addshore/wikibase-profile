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

# Get the ball (and id counters rolling) with some simple entities..
make_request "new=item" "data={}"
make_request "new=property" "data={\"datatype\":\"string\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}"

# Then do the bulk of the stuff

# Create some properties
# P2 = wikibase-item
# P3 = wikibase-property
# P4 = string
# P5 = time
properties=( wikibase-item wikibase-property string time )
for p in "${properties[@]}"
do
  make_request "new=property" "data={\"datatype\":\"${p}\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}"
done

# Create some items including statements

# 2500 with strings
for i in {1..2500}
do
  (
    make_request "new=item" "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P4\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P4\",\"datavalue\":{\"value\":\"statement-string-value\",\"type\":\"string\"},\"datatype\":\"string\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}"
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then sleep 0.5; fi
done

# 2500 linking to other items
for i in {1..2500}
do
  (
    make_request "new=item" "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P2\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P2\",\"datavalue\":{\"value\":{\"entity-type\":\"item\",\"numeric-id\":1,\"id\":\"Q1\"},\"type\":\"wikibase-entityid\"},\"datatype\":\"wikibase-item\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}"
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then sleep 0.5; fi
done

wait