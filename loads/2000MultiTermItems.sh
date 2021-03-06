for i in {1..2000}
do
  (
    curl -s -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F "data={\"labels\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"descriptions\":{\"en\":{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}},\"aliases\":{\"en\":[{\"language\":\"en\",\"value\":\"$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 30))\"}]}}" http://localhost:8181/w/api.php >> process.out
  )&
  if (( $(wc -w <<<$(jobs -p)) % 20 == 0 )); then wait; fi
done