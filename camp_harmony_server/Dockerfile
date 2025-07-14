# Build stage
FROM dart:3.5.0 AS build
RUN git clone --branch stable --depth 10 https://github.com/flutter/flutter.git /flutter \
    && /flutter/bin/flutter --version
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"
WORKDIR /app

COPY camp_harmony_server/ camp_harmony_server/
COPY camp_harmony_client/ camp_harmony_client/

WORKDIR /app/camp_harmony_server

# Install serverpod_cli globally
RUN dart pub global activate serverpod_cli

# Install dependencies and compile the server executable
RUN dart pub get
RUN serverpod generate
RUN dart compile exe bin/main.dart -o bin/server

# Final stage
FROM alpine:latest

RUN apk add --no-cache openssl ca-certificates

# Environment variables
ENV runmode=production
ENV serverid=default
ENV logging=normal
ENV role=monolith

WORKDIR /app

COPY --from=build /app/camp_harmony_server/bin/server ./server

# Copy runtime dependencies
COPY --from=build /app/camp_harmony_server/runtime/ /

# Copy compiled server executable
COPY --from=build /app/camp_harmony_server/bin/server server

# Copy configuration files and resources
COPY --from=build /app/camp_harmony_server/config/ config/
COPY --from=build /app/camp_harmony_server/web/ web/
COPY --from=build /app/camp_harmony_server/migrations/ migrations/

# This file is required to enable the endpoint log filter in Insights.
COPY --from=build /app/camp_harmony_server/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

# Expose ports
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

# Define the entrypoint command
ENTRYPOINT ./server --mode=$runmode --server-id=$serverid --logging=$logging --role=$role
