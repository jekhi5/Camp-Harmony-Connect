BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "users" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "name" text NOT NULL,
    "email" text NOT NULL,
    "phoneNumber" text NOT NULL,
    "registrationDate" timestamp without time zone NOT NULL,
    "isActive" boolean NOT NULL,
    "roles" json NOT NULL,
    "profilePictureUrl" text,
    "lastLogin" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR camp_harmony
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('camp_harmony', '20250707200119130', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250707200119130', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
