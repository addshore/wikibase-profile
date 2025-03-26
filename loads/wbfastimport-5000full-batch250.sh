# Get the ball (and id counters rolling) with some simple entities..
# Using wbfastimport for the item to try and get the error like https://phabricator.wikimedia.org/P47263
curl -s -m 20 -X POST -F 'action=wbfastimport' -F 'format=json' -F 'data={\"type\":\"item\"}' http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php >> process.out && echo >> process.out
curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'new=property' -F "data={\"datatype\":\"string\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php >> process.out && echo >> process.out

# # Create some properties
# # P2 = wikibase-item
# # P3 = wikibase-property
# # P4 = string
# # P5 = time
# properties=( wikibase-item wikibase-property string time )
# for p in "${properties[@]}"
# do
#   curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=property' -F "data={\"datatype\":\"${p}\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php >> process.out && echo >> process.out
# done

# Do bulk stuff

BATCH_SIZE=250
ENTITY_LIMIT=5000

# For each batch
for i in $(seq 0 $((ENTITY_LIMIT / BATCH_SIZE - 1)))
# Get the contents of the file
do
  # Get the contents of the file
  DATA=$(cat ./fastbatch-${i}.json.tmp)

  # Post the contents of the file
  (
    curl -s -m 20 -X POST -F 'action=wbfastimport' -F 'format=json' -F "data=${DATA}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php >> process.out && echo >> process.out
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then sleep 0.5; fi
done