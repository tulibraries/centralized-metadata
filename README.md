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

Existing documentation can be found in spec/requests/records_spec.rb. If you need to edit this file, be sure to run the `bundle exec rails rswag` command to run the updates.
