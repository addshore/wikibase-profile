# wikibase-profile

The general idea of this repo is to allow some basic profiling of different setups of Wikibase, using Docker, in a mildly automated way.

Steps:

- Startup docker-compose with wikibase and mysql
- Wait for it to be running
- Run install & update
- Start a timer
- Do some amount of known work
- Stop timer
- Output result...

## Local profiling

You can also try running them locally...

Setup matrix.yml to your liking, and then run the following command:

```sh
./run_matrix.sh
```

You'll find some useful stuff output, but also in the `.data` directory, which will contain the results of the profiling.
