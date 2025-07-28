BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "fcm_tokens" (
    "id" bigserial PRIMARY KEY,
    "token" text NOT NULL,
    "userId" bigint NOT NULL
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
    VALUES ('camp_harmony', '20250728163922312', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250728163922312', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
