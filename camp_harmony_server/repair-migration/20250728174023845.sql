BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_user_info" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_user_image" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_email_auth" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_key" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_google_refresh_token" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_email_reset" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_email_failed_sign_in" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_email_create_request" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fcm_tokens" (
    "id" bigserial PRIMARY KEY,
    "token" text NOT NULL,
    "userId" bigint NOT NULL,
    "lastUpdate" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "fcm_tokens"
    ADD CONSTRAINT "fcm_tokens_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "users"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR camp_harmony
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('camp_harmony', '20250728173358407', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250728173358407', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();

--
-- MIGRATION VERSION FOR _repair
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('_repair', '20250728174023845', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250728174023845', "timestamp" = now();


--
-- MIGRATION VERSION FOR 'serverpod_auth'
--
DELETE FROM "serverpod_migrations"WHERE "module" IN ('serverpod_auth');

COMMIT;
