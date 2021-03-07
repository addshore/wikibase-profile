# Get the ball (and id counters rolling) with some simple entities..
curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F 'data={}' http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php
curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=property' -F "data={\"datatype\":\"string\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php

# Then do the bulk of the stuff

# Divice ASYNC by 2, as we do 2 loops at the same time..
ASYNC=$(expr $ASYNC / 2)

(for i in {1..1000}
do
  (
    curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then wait; fi
done)&
(for i in {1..1000}
do
  (
    curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then wait; fi
done)&

wait