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