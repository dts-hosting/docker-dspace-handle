# docker-dspace-handle

A standalone handle server implementation for DSpace. It builds on:

- [docker-handle](https://github.com/datacite/docker-handle)
  - the above project provides a reference implementation only (no fork)
- [Remote Handle Resolver](https://github.com/DSpace/Remote-Handle-Resolver)
  - [Patched Remote Handle Resolver](https://github.com/cnri/Remote-Handle-Resolver)

Refer to the DSpace wiki documentation [handle.net integration](https://wiki.lyrasis.org/display/DSDOC7x/Handle.Net+Registry+Support#Handle.NetRegistrySupport-ToinstallaHandleresolveronaseparatemachine)
for extended details.

## Building the Remote Handle Resolver

The current release version of the handle resolver is out of date.
See this PR for details: https://github.com/DSpace/Remote-Handle-Resolver/pull/2

This repository provides an updated build at `lib/dspace-remote-handle-resolver-1.1-SNAPSHOT.jar`.

To re/create a build (requires Java / Maven):

1. Clone the repository

```bash
mkdir -p src
git -C src clone https://github.com/cnri/Remote-Handle-Resolver
```

2. Run a build

```bash
cd src/Remote-Handle-Resolver
mvn clean install -DskipTests
cd -
cp src/Remote-Handle-Resolver/target/dspace-remote-handle-resolver-1.1-SNAPSHOT.jar lib/
```

## Build the Docker handle server image

```bash
docker compose build
```

## Run the image locally for testing

```bash
docker compose up
```

## DSpace plugin cfg

For the time being `handle-dspace-plugin.cfg` is embedded with this repository.

When a new site is added this file will need to be updated, the handle server
redeployed, and a handle prefix registration request will need to be made to
the handle.net folks. See below for more details on that and on ideas for
handling the plugin cfg differently in the future.

## Re/generating keys

If keys needs to be regenerated the PRIVATE_KEY and PUBLIC_KEY need to be in
pksc8 format:

```bash
ssh-keygen -m pkcs8 -f mykey.pem
# Get it in a format for PKCS8 and put in explicit new lines ready for env var
openssl pkcs8 -topk8 -in mykey.pem -nocrypt | sed ':a;N;$!ba;s/\n/\\r\\n/g'
openssl pkcs8 -topk8 -in mykey.pem -nocrypt | openssl pkey -pubout | sed ':a;N;$!ba;s/\n/\\r\\n/g'
```

For remote deployments the keys are uploaded to SSM:

- handle-private-key-pem
- handle-public-key-pem

## sitebndl.zip

The `sitebndl.zip` is a collection if files that need to be submitted
with handle prefix registration requests.

```bash
# the handle server must be running
docker compose up -d
make sitebndl # local server

# for a remote ecs service
make sitebndl service=$service
```

This will only have to be done once (per handle server deployment).

Components of `sitebndl`:

- `admpub.bin` located in container at: `/var/handle/svr/admpub.bin`
- `contactdata.dct` located in container at: `/var/handle/svr/contactdata.dct`
- `repl_admin` located in container at: `/var/handle/svr/repl_admin`
- `siteinfo.json` located in container at: `/var/handle/svr/siteinfo.json`

The only relevant parts for DSpace/Direct (seemingly) are the siteinfo
and contactdata.

_When registering prefixes the same `sitebndl.zip` can be submitted each time
as those details don't change with a standalone handle server._

## Registration request for new site

TODO

## Ideas for handle-dspace-plugin.cfg

In the future it may be preferable to manage the `handle-dspace-plugin.cfg` differently.

Some ideas for that:

- Delete the embedded copy of the file and .gitignore it
- Generate the cfg in this repo but as part of the Docker build workflow
  - The data would be pulled from somewhere else (such as tagdb)
  - Post image build trigger a restart of the deployed service
- Alternatively, update the image to pull the cfg from a url (s3 or otherwise)
  - The cfg would be downloaded on startup
  - The cfg generation would be elsewhere and uploaded to s3
  - Use an s3 -> lambda notification to restart the deployed service
  - This nicely decouples this image build repository from the cfg generation
