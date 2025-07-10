BEGIN;


--
-- MIGRATION VERSION FOR camp_harmony
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('camp_harmony', '20250710205603697', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250710205603697', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
