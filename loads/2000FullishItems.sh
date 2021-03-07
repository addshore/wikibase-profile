# Get the ball (and id counters rolling) with some simple entities..
curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F 'data={}' http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php
curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=property' -F "data={\"datatype\":\"string\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php

# Then do the bulk of the stuff

# Divice ASYNC by 2, as we do 2 loops at the same time..
ASYNC=$(expr $ASYNC / 2)

# Create some properties
# P2 = wikibase-item
# P3 = wikibase-property
# P4 = string
# P5 = time
properties=( wikibase-item wikibase-property string time )
for p in "${properties[@]}"
do
  curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=property' -F "data={\"datatype\":\"${p}\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php
done

# Create some items including statements

# 1000 with strings
(for i in {1..1000}
do
  (
    curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P4\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P4\",\"datavalue\":{\"value\":\"statement-string-value\",\"type\":\"string\"},\"datatype\":\"string\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then wait; fi
done)&

# 1000 linking to other items
(for i in {1..1000}
do
  (
    curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P2\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P2\",\"datavalue\":{\"value\":{\"entity-type\":\"item\",\"numeric-id\":1,\"id\":\"Q1\"},\"type\":\"wikibase-entityid\"},\"datatype\":\"wikibase-item\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then wait; fi
done)&

wait