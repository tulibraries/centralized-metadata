# Centralized Metadata Repository

An API built with Rails that stores name authority records with corresponding local metadata.

See also https://github.com/tulibraries/centralized-metadata-dags. 

## System Requirements 

TO DO

## Getting Started 

TO DO

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