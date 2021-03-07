# wikibase-profile

The general idea of this repo is to allow some basic profiling of different settings using docker and possible GIthub actions?

Steps:

- Startup docker-compose with wikibase and mysql
- Wait for it to be running
- Run install & update
- Start a timer
- Do some amount of known work
- Stop timer
- Output result...
- Send result to Google Sheet via IFTTT

You can also try running them locally... For example...

```sh
PROFILE_IMAGE=wikibase/wikibase:1.35-base PROFILE_SETTINGS=lightweight PROFILE_SQL=mariadb:10.5 docker-compose up -d
./docker-compose-wait1.sh
./docker-compose-wait2.sh
sleep 3
ASYNC=40 INSTANCES=2 ./loads/2000EmptyItems.sh
```
