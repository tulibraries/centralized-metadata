# Centralized Metadata Repository

An API built with Rails that stores name authority records with corresponding local metadata.

See also https://github.com/tulibraries/centralized-metadata-dags. 

## System Requirements 

Postgres DB: latest
Ruby: latest

## Getting Started 

If you don't already have postgres installed, make sure to do that.  On Macs you can install postgres with the following command:

```
brew install postgresql
```

Next, make sure the postgres server is running. On Macs you can check the status of the database with the command:

```
brew services
```

If postgresql is not running then start it with:

```
brew services start postgresql
```

Make sure you have a DB user called "posgres" that can be used to run the app.  On Macs you can use the following command:

``
createuser --superuser postgres
```

## Creating records with MARC files

### Option 1: Use the API controller

Use curl to upload files to a running instance of the application

Example 

```
curl -F "marc_file=@spec/fixtures/marc/louis_armstrong.mrc" https://centralized-metadata-qa.k8s.temple.edu/records
```

### Option 2: Use the rake task

Individual file
```
rake  db:ingest[spec/fixtures/marc/louis_armstrong.mrc]
```

File directory

```
rake  db:ingest[spec/fixtures/marc]
```

## API Documentation

This API uses [Rswag](https://github.com/rswag/rswag) to generate swagger documentation.  

Use Swagger tests in spec/requests to describe and test the API operations. Run the `bundle exec rails rswag` command to generate and update the swagger.yaml file based on the tests. Do not update the swagger.yaml file directly.
