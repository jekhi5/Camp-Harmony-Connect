# Camp Harmony Connect - Server

# Setup:

This is the starting point for the Serverpod server.

- Download and install [Docker](https://www.docker.com/products/docker-desktop/)
- Create a `.env` file and create the variables stored in `.env.example`
- Create a `config/passwords.yaml` file and copy in the fields stored in `config/passwords.example.yaml`
- Run `dart pub get`
- Run `serverpod generate` to generate all necessary server files
- If you've modified any of the schemas, be sure to run `serverpod create-migration`
- Run `docker compose up --build --detach` to start the docker container
- Run `dart bin/main.dart` to start the server

  - If you need to apply any migrations, run `dart bin/main.dart --apply-migrations`

- When you are finished, you can shut down Serverpod with `Ctrl-C`, then stop Postgres and Redis.
  - docker compose stop
