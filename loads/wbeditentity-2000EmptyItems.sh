# Get the ball (and id counters rolling) with some simple entities..
curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F 'data={}' http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php >> process.out && echo >> process.out
curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=property' -F "data={\"datatype\":\"string\",\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}}}" http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php >> process.out && echo >> process.out

# Then do the bulk of the stuff

for i in {1..2000}
do
  (
    curl -s -m 20 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F 'data={}' http://localhost:818$((1 + RANDOM % $INSTANCES))/w/api.php >> process.out && echo >> process.out
  )&
  if (( $(wc -w <<<$(jobs -p)) % $ASYNC == 0 )); then sleep 0.5; fi
done

wait