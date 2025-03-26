# wikibase-profile

The general idea of this repo is to allow some basic profiling of different settings using docker and possible Github actions?

Steps:

- Startup docker-compose with wikibase and mysql
- Wait for it to be running
- Run install & update
- Start a timer
- Do some amount of known work
- Stop timer
- Output result...
- Send result to Google Sheet via IFTTT

## Local profiling

You can also try running them locally... For example...

```sh
export PROFILE_IMAGE=wikibase/wikibase:1.39.1-wmde.11
export PROFILE_SETTINGS=default
export PROFILE_SQL=mariadb:10.9

docker-compose up -d mysql wikibase1
./docker-compose-wait1.sh
docker-compose up -d wikibase2
./docker-compose-wait2.sh
docker-compose up -d --force-recreate wikibase1
./docker-compose-wait1.sh

echo "Sleeping for 5 seconds..."
sleep 5
echo "Starting profiling..."
TIMING=$(time ASYNC=30 INSTANCES=2 ./loads/wbeditentity-2000EmptyItems.sh)
LAST_LINE=$(tail -n 1 ./process.out)
STATS=$(curl 'http://localhost:8181/w/api.php?action=query&format=json&meta=siteinfo&siprop=statistics')
```

And to delete everything, just...

```sh
docker-compose down --volumes
```