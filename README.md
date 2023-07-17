# Centralized Metadata

## Uploading files

Use curl to upload files to a running instance of the application

Example:


### Using the API controller
```
curl -F "marc_file=@spec/fixtures/marc/louis_armstrong.mrc" https://centralized-metadata-qa.k8s.temple.edu/records

```

### Using the rake task
```
rake  db:ingest[spec/fixtures/marc/louis_armstrong.mrc]
```

Or pass in a directory to ingest all *.mrc content inside said directory:

```
rake  db:ingest[spec/fixtures/marc]
```

## API Documentation

This API uses [Rswag](https://github.com/rswag/rswag) to generate swagger documentation.  

Existing documentation can be found in the `spec/requests` folder for the various API endpoints. This file gets built automatically in the deployed environment but locally you should run either `make rswag`  or `bundle exec rake rswag` in order to build the file and see changes applied to the API UI interface.
