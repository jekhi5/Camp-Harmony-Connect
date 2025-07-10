BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "users" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "users" (
    "id" bigserial PRIMARY KEY,
    "firebaseUID" text NOT NULL,
    "firstName" text NOT NULL,
    "lastName" text NOT NULL,
    "email" text NOT NULL,
    "phoneNumber" text NOT NULL,
    "registrationDate" timestamp without time zone NOT NULL,
    "isActive" boolean NOT NULL,
    "roles" json NOT NULL,
    "onboardingCompleted" boolean NOT NULL
);


--
-- MIGRATION VERSION FOR camp_harmony
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('camp_harmony', '20250709185445578', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250709185445578', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
