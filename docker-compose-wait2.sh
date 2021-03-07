#!/bin/bash

repo_path=$(dirname $(dirname $(realpath $0)))

# Wait for apache to actually be running
for i in {1..30}
do
    docker-compose logs wikibase2 | grep "+ apache2-foreground" | wc -l | grep 1
    # Perhaps we should use greater than? Or output if it is greater than!!!!
    if [ $? -eq 0 ]
    then
        sleep 1
        break
    fi
    sleep 1
done

echo "Done!"