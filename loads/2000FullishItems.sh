# Create some properties
# P1 = wikibase-item
# P2 = wikibase-property
# P3 = string
# P4 = time
properties=( wikibase-item wikibase-property string time )
for p in "${properties[@]}"
do
  curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=property' -F "data={\"datatype\":\"${p}\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:8181/w/api.php
done

# Create some items including statements

# 1000 with strings
for i in {1..1000}
do
  (
    curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P3\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P3\",\"datavalue\":{\"value\":\"statement-string-value\",\"type\":\"string\"},\"datatype\":\"string\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}" http://localhost:8181/w/api.php
  )&
  if (( $(wc -w <<<$(jobs -p)) % 40 == 0 )); then wait; fi
done

# 1000 linking to other items
for i in {1..1000}
do
  (
    curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]},\"claims\":{\"P1\":[{\"mainsnak\":{\"snaktype\":\"value\",\"property\":\"P1\",\"datavalue\":{\"value\":{\"entity-type\":\"item\",\"numeric-id\":1,\"id\":\"Q1\"},\"type\":\"wikibase-entityid\"},\"datatype\":\"wikibase-item\"},\"type\":\"statement\",\"rank\":\"normal\"}]}}" http://localhost:8181/w/api.php
  )&
  if (( $(wc -w <<<$(jobs -p)) % 40 == 0 )); then wait; fi
done