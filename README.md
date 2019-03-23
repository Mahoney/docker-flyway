# Flyway docker image [![CircleCI](https://circleci.com/gh/Mahoney/docker-flyway/tree/master.svg?style=svg)](https://circleci.com/gh/Mahoney/docker-flyway/tree/master)

## What is Flyway?

![logo](logo.png)

[Flyway](https://flywaydb.org/) is an open source database migration tool. It
strongly favors simplicity and convention over configuration.

It is based around 6 basic commands: Migrate, Clean, Info, Validate, Baseline
and Repair.

Migrations can be written in SQL (database-specific syntax (such as PL/SQL,
T-SQL, ...) is supported) or Java (for advanced data transformations or dealing
with LOBs).

It has a Command-line client, a Java API (also works on Android) for migrating
the database on application startup, a Maven plugin, Gradle plugin, SBT plugin
and Ant tasks.

Plugins are available for Spring Boot, Dropwizard, Grails, Play, Griffon,
Grunt, Ninja and more.

Supported databases are Oracle, SQL Server, SQL Azure, DB2, DB2 z/OS, MySQL
(including Amazon RDS), MariaDB, Google Cloud SQL, PostgreSQL (including Amazon
RDS and Heroku), Redshift, Vertica, H2, Hsql, Derby, SQLite, SAP HANA, solidDB,
Sybase ASE and Phoenix.

## Usage

### How to use this image


To run a schema migration, you have to mount the folder containing migration
scripts in a volume under `/flyway/sql`. 

Assuming your DB is a PostgreSQL Database, running a schema migration is simple as this:  


```bash
docker run --rm \
  -v ${PWD}:/flyway/sql 
  teviotia/flyway \
  -user=postgres \
  -password=password \
  -url=jdbc:postgresql://postgres/postgres \
  migrate
```

### Waiting for the DB


It is common when using tools like Docker Compose to depend on services in
other linked containers,  however often relying on links is not enough - whilst
the container itself may have started, the service(s) within it may not yet be
ready.

That's typically the case when we use Docker Compose to run migration on a DB
managed in a container. Whilst the container itself may have started, the
database service is not reachable immediately, so the database migration might
fail.

Unfortunately with Postgres even a tcp polling solution such as Dockerize
fails, because the database starts listening on the port before it is ready to
accept connections.

That's why this image provides an exponentially backing off bash function to
allow retrying until success. By default it will try 7 times over the course of
about 16 seconds in total. 

Here is a [sample](sample) using PostgreSQL:

```yaml
version: '3'

services:

  # Database
  db:
    image: postgres:9.6.3
    ports:
      - 5432:5432
    environment:
      POSTGRES_PASSWORD: password

  # Database Schema migration
  schema:
    image: teviotia/flyway
    entrypoint: with_backoff
    command: >
      flyway
      -user=postgres
      -password=password
      -url=jdbc:postgresql://db/postgres
      migrate
    volumes:
      - "./db:/flyway/sql"
    depends_on:
      - db
```


## Build

This project is built by Circle CI at https://circleci.com/gh/Mahoney/docker-flyway.

## License

All the code contained in this repository, unless explicitly stated, is
licensed under ISC license.

A copy of the license can be found inside the [LICENSE](LICENSE) file.

## Attribution

Forked from [bandsintown/docker-flyway](https://github.com/bandsintown/docker-flyway).

Backoff script adapted from https://coderwall.com/p/--eiqg/exponential-backoff-in-bash
