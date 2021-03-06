# Make 100 empty items...
for i in {1..500}
do
  curl -s -X POST -F 'action=wbeditentity' -F 'format=json' -F 'token=+\' -F 'new=item' -F 'data={}' http://localhost:8181/w/api.php >> process.out
done