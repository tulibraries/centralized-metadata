# Centralized Metadata

## Uploading files

Use curl to upload files to a running instance of the application

Example:


### Using the API controller
```
curl -F "marc_file=@spec/fixtures/marc/louis_armstrong.mrc" https://centralized-metadata-qa.k8s.temple.edu

```

### Using the rake task
```
rake  db:ingest[spec/fixtures/marc/louis_armstrong.mrc]
```

Or pass in a directory to ingest all *.mrc content inside said directory:

```
rake  db:ingest[spec/fixtures/marc]
```
