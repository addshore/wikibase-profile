for i in {1..2000}
do
  (
    curl -s -m 10 -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F 'data={}' http://localhost:8181/w/api.php >> process.out
  )&
  if (( $(wc -w <<<$(jobs -p)) % 20 == 0 )); then wait; fi
done