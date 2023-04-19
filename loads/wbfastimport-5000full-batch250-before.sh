# Prepare bulk stuff

BATCH_SIZE=250
ENTITY_LIMIT=5000

# Collect entities in files
for i in $(seq 1 $ENTITY_LIMIT)
do
    # Figure out what batch we are in
    BATCH=$((i / BATCH_SIZE))

    # Add a { to the start of file before the first entity of the batch
    if [ $((i % BATCH_SIZE)) -eq 1 ]
    then
        echo '[' > ./fastbatch-${BATCH}.json.tmp
    fi

    # Switch item type based on number
    if [ $i -lt 1000 ]
    then
        echo "{\"type\":\"item\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P4\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P4\",\"datavalue\":{\"value\":\"statement-string-value\",\"type\":\"string\"},\"datatype\":\"string\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}," >> ./fastbatch-${BATCH}.json.tmp
    else
        echo "{\"type\":\"item\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P2\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P2\",\"datavalue\":{\"value\":{\"entity-type\":\"item\",\"numeric-id\":1,\"id\":\"Q1\"},\"type\":\"wikibase-entityid\"},\"datatype\":\"wikibase-item\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}," >> ./fastbatch-${BATCH}.json.tmp
    fi
done

# Trim the last 2 chars from all files, and add a } to close the JSON
for i in $(seq 0 $((ENTITY_LIMIT / BATCH_SIZE - 1)))
do
    # Trim the last 2 chars from the file
    sed -i '$ s/.$//' ./fastbatch-${i}.json.tmp
    echo ']' >> ./fastbatch-${i}.json.tmp
done
