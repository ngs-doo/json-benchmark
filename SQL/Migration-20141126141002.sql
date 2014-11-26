/*MIGRATION_DESCRIPTION
--REMOVE: StandardObjects-DeletePost-reason
Property reason will be removed from object DeletePost in schema StandardObjects
--REMOVE: StandardObjects-DeletePost-post
Property post will be removed from object DeletePost in schema StandardObjects
--REMOVE: StandardObjects-DeletePost
Object DeletePost will be removed from schema StandardObjects
--REMOVE: SmallObjects-Message-message
Property message will be removed from object Message in schema SmallObjects
--REMOVE: SmallObjects-Message
Object Message will be removed from schema SmallObjects
--REMOVE: LargeObjects-Page-illustrations
Property illustrations will be removed from object Page in schema LargeObjects
--REMOVE: LargeObjects-Book-backCover
Property backCover will be removed from object Book in schema LargeObjects
--REMOVE: LargeObjects-Book-frontCover
Property frontCover will be removed from object Book in schema LargeObjects
--CREATE: LargeObjects-Book-cover
New property cover will be created for Book in LargeObjects
--CREATE: LargeObjects-Book-genres
New property genres will be created for Book in LargeObjects
--CREATE: LargeObjects-Genre
New object Genre will be created in schema LargeObjects
--CREATE: LargeObjects-Genre-Action
New enum label Action will be added to enum object Genre in schema LargeObjects
--CREATE: LargeObjects-Genre-Romance
New enum label Romance will be added to enum object Genre in schema LargeObjects
--CREATE: LargeObjects-Genre-Comedy
New enum label Comedy will be added to enum object Genre in schema LargeObjects
--CREATE: LargeObjects-Genre-SciFi
New enum label SciFi will be added to enum object Genre in schema LargeObjects
--CREATE: LargeObjects-Note-writtenBy
New property writtenBy will be created for Note in LargeObjects
--CREATE: SmallObjects-Message
New object Message will be created in schema SmallObjects
--CREATE: SmallObjects-Message-message
New property message will be created for Message in SmallObjects
--CREATE: SmallObjects-Message-version
New property version will be created for Message in SmallObjects
--CREATE: StandardObjects-DeletePost
New object DeletePost will be created in schema StandardObjects
--CREATE: StandardObjects-DeletePost-postID
New property postID will be created for DeletePost in StandardObjects
--CREATE: StandardObjects-DeletePost-lastModified
New property lastModified will be created for DeletePost in StandardObjects
--CREATE: StandardObjects-DeletePost-deletedBy
New property deletedBy will be created for DeletePost in StandardObjects
--CREATE: StandardObjects-DeletePost-reason
New property reason will be created for DeletePost in StandardObjects
--CREATE: LargeObjects-Footnote-writtenBy
New property writtenBy will be created for Footnote in LargeObjects
--CREATE: LargeObjects-Headnote-writtenBy
New property writtenBy will be created for Headnote in LargeObjects
MIGRATION_DESCRIPTION*/

DO $$ BEGIN
	IF EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = '-NGS-' AND c.relname = 'database_setting') THEN	
		IF EXISTS(SELECT * FROM "-NGS-".Database_Setting WHERE Key ILIKE 'mode' AND NOT Value ILIKE 'unsafe') THEN
			RAISE EXCEPTION 'Database upgrade is forbidden. Change database mode to allow upgrade';
		END IF;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM pg_constraint c JOIN pg_class r ON c.conrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace JOIN pg_description d ON c.oid = d.objoid WHERE c.conname = 'fk_pages' AND n.nspname = 'LargeObjects' AND r.relname = 'Page' AND d.description LIKE 'NGS generated%') THEN
		ALTER TABLE "LargeObjects"."Page" DROP CONSTRAINT "fk_pages";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM pg_index i JOIN pg_class r ON i.indexrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace JOIN pg_description d ON r.oid = d.objoid AND d.objsubid = 0 WHERE n.nspname = 'StandardObjects' AND r.relname = 'ix_unprocessed_events_StandardObjects_DeletePost' AND d.description LIKE 'NGS generated%') THEN
		DROP INDEX "StandardObjects"."ix_unprocessed_events_StandardObjects_DeletePost";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM pg_index i JOIN pg_class r ON i.indexrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace JOIN pg_description d ON r.oid = d.objoid AND d.objsubid = 0 WHERE n.nspname = 'SmallObjects' AND r.relname = 'ix_unprocessed_events_SmallObjects_Message' AND d.description LIKE 'NGS generated%') THEN
		DROP INDEX "SmallObjects"."ix_unprocessed_events_SmallObjects_Message";
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Book_to_type"("LargeObjects"."-ngs_Book_type-") RETURNS "LargeObjects"."Book_entity" AS $$ SELECT $1::text::"LargeObjects"."Book_entity" $$ IMMUTABLE LANGUAGE sql;
CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Book_to_type"("LargeObjects"."Book_entity") RETURNS "LargeObjects"."-ngs_Book_type-" AS $$ SELECT $1::text::"LargeObjects"."-ngs_Book_type-" $$ IMMUTABLE LANGUAGE sql;

CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."-ngs_Page_type-") RETURNS "LargeObjects"."Page_entity" AS $$ SELECT $1::text::"LargeObjects"."Page_entity" $$ IMMUTABLE LANGUAGE sql;
CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."Page_entity") RETURNS "LargeObjects"."-ngs_Page_type-" AS $$ SELECT $1::text::"LargeObjects"."-ngs_Page_type-" $$ IMMUTABLE LANGUAGE sql;

DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-insert764896781<";
DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-update764896781<";
DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-delete764896781<";;
DROP VIEW IF EXISTS "LargeObjects"."Book_unprocessed_events";

DROP FUNCTION IF EXISTS "LargeObjects"."persist_Book"("LargeObjects"."Book_entity"[], "LargeObjects"."Book_entity"[], "LargeObjects"."Book_entity"[], "LargeObjects"."Book_entity"[]);
DROP FUNCTION IF EXISTS "LargeObjects"."persist_Book_internal"(int, int);
DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-insert<";
DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-update<";
DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-delete<";;

DROP CAST IF EXISTS ("LargeObjects"."-ngs_Book_type-" AS "LargeObjects"."Book_entity");
DROP CAST IF EXISTS ("LargeObjects"."Book_entity" AS "LargeObjects"."-ngs_Book_type-");
DROP FUNCTION IF EXISTS "LargeObjects"."cast_Book_to_type"("LargeObjects"."-ngs_Book_type-");
DROP FUNCTION IF EXISTS "LargeObjects"."cast_Book_to_type"("LargeObjects"."Book_entity");
DROP FUNCTION IF EXISTS "StandardObjects"."submit_DeletePost"("StandardObjects"."DeletePost_event"[]);
DROP FUNCTION IF EXISTS "SmallObjects"."submit_Message"("SmallObjects"."Message_event"[]);

DROP CAST IF EXISTS ("LargeObjects"."-ngs_Page_type-" AS "LargeObjects"."Page_entity");
DROP CAST IF EXISTS ("LargeObjects"."Page_entity" AS "LargeObjects"."-ngs_Page_type-");
DROP FUNCTION IF EXISTS "LargeObjects"."cast_Page_to_type"("LargeObjects"."-ngs_Page_type-");
DROP FUNCTION IF EXISTS "LargeObjects"."cast_Page_to_type"("LargeObjects"."Page_entity");
DROP FUNCTION IF EXISTS "StandardObjects"."mark_DeletePost"(BIGINT[]);
DROP FUNCTION IF EXISTS "SmallObjects"."mark_Message"(BIGINT[]);
DROP VIEW IF EXISTS "LargeObjects"."Book_entity";
DROP VIEW IF EXISTS "StandardObjects"."DeletePost_event";
DROP VIEW IF EXISTS "SmallObjects"."Message_event";
DROP VIEW IF EXISTS "LargeObjects"."Page_entity";
ALTER TABLE "StandardObjects"."DeletePost" DROP COLUMN IF EXISTS "reason";
ALTER TABLE "StandardObjects"."DeletePost" DROP COLUMN IF EXISTS "post";
ALTER TABLE "SmallObjects"."Message" DROP COLUMN IF EXISTS "message";

DO $$ BEGIN
	IF EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Page' AND column_name = 'illustrations' AND is_ngs_generated) THEN
		ALTER TABLE "LargeObjects"."Page" DROP COLUMN "illustrations";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Page_type-' AND column_name = 'illustrations' AND is_ngs_generated) THEN
		ALTER TYPE "LargeObjects"."-ngs_Page_type-" DROP ATTRIBUTE "illustrations";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'backCover' AND is_ngs_generated) THEN
		ALTER TABLE "LargeObjects"."Book" DROP COLUMN "backCover";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'backCover' AND is_ngs_generated) THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" DROP ATTRIBUTE "backCover";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'frontCover' AND is_ngs_generated) THEN
		ALTER TABLE "LargeObjects"."Book" DROP COLUMN "frontCover";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'frontCover' AND is_ngs_generated) THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" DROP ATTRIBUTE "frontCover";
	END IF;
END $$ LANGUAGE plpgsql;
ALTER TYPE "LargeObjects"."-ngs_Book_type-" DROP ATTRIBUTE IF EXISTS "pagesURI";

DO $$ BEGIN
	IF EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace JOIN pg_description d ON c.oid = d.objoid AND d.objsubid = 0 WHERE n.nspname = 'StandardObjects' AND c.relname = 'DeletePost' AND d.description LIKE 'NGS generated%') THEN
		DROP TABLE "StandardObjects"."DeletePost";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace JOIN pg_description d ON c.oid = d.objoid AND d.objsubid = 0 WHERE n.nspname = 'SmallObjects' AND c.relname = 'Message' AND d.description LIKE 'NGS generated%') THEN
		DROP TABLE "SmallObjects"."Message";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre') THEN	
		CREATE TYPE "LargeObjects"."Genre" AS ENUM ('Action', 'Romance', 'Comedy', 'SciFi');
		COMMENT ON TYPE "LargeObjects"."Genre" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'SmallObjects' AND t.typname = '-ngs_Message_type-') THEN	
		CREATE TYPE "SmallObjects"."-ngs_Message_type-" AS ();
		COMMENT ON TYPE "SmallObjects"."-ngs_Message_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'SmallObjects' AND t.typname = 'Message') THEN	
		CREATE TYPE "SmallObjects"."Message" AS ();
		COMMENT ON TYPE "SmallObjects"."Message" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = '-ngs_DeletePost_type-') THEN	
		CREATE TYPE "StandardObjects"."-ngs_DeletePost_type-" AS ();
		COMMENT ON TYPE "StandardObjects"."-ngs_DeletePost_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'DeletePost') THEN	
		CREATE TYPE "StandardObjects"."DeletePost" AS ();
		COMMENT ON TYPE "StandardObjects"."DeletePost" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'pagesURI') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "pagesURI" VARCHAR[];
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."pagesURI" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'cover') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "cover" BYTEA;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."cover" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'cover') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "cover" BYTEA;
		COMMENT ON COLUMN "LargeObjects"."Book"."cover" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'genres') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "genres" "LargeObjects"."Genre"[];
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."genres" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'genres') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "genres" "LargeObjects"."Genre"[];
		COMMENT ON COLUMN "LargeObjects"."Book"."genres" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre' AND e.enumlabel = 'Action') THEN
		--ALTER TYPE "LargeObjects"."Genre" ADD VALUE IF NOT EXISTS 'Action'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Action', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre' AND e.enumlabel = 'Romance') THEN
		--ALTER TYPE "LargeObjects"."Genre" ADD VALUE IF NOT EXISTS 'Romance'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Romance', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre' AND e.enumlabel = 'Comedy') THEN
		--ALTER TYPE "LargeObjects"."Genre" ADD VALUE IF NOT EXISTS 'Comedy'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Comedy', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre' AND e.enumlabel = 'SciFi') THEN
		--ALTER TYPE "LargeObjects"."Genre" ADD VALUE IF NOT EXISTS 'SciFi'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'SciFi', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'LargeObjects' AND t.typname = 'Genre';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Note_type-' AND column_name = 'writtenBy') THEN
		ALTER TYPE "LargeObjects"."-ngs_Note_type-" ADD ATTRIBUTE "writtenBy" VARCHAR(100);
		COMMENT ON COLUMN "LargeObjects"."-ngs_Note_type-"."writtenBy" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Note' AND column_name = 'writtenBy') THEN
		ALTER TYPE "LargeObjects"."Note" ADD ATTRIBUTE "writtenBy" VARCHAR(100);
		COMMENT ON COLUMN "LargeObjects"."Note"."writtenBy" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "SmallObjects"."cast_Message_to_type"("SmallObjects"."Message") RETURNS "SmallObjects"."-ngs_Message_type-" AS $$ SELECT $1::text::"SmallObjects"."-ngs_Message_type-" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION "SmallObjects"."cast_Message_to_type"("SmallObjects"."-ngs_Message_type-") RETURNS "SmallObjects"."Message" AS $$ SELECT $1::text::"SmallObjects"."Message" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION cast_to_text("SmallObjects"."Message") RETURNS text AS $$ SELECT $1::VARCHAR $$ IMMUTABLE LANGUAGE sql COST 1;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'SmallObjects' AND s.typname = 'Message' AND t.typname = '-ngs_Message_type-') THEN
		CREATE CAST ("SmallObjects"."-ngs_Message_type-" AS "SmallObjects"."Message") WITH FUNCTION "SmallObjects"."cast_Message_to_type"("SmallObjects"."-ngs_Message_type-") AS IMPLICIT;
		CREATE CAST ("SmallObjects"."Message" AS "SmallObjects"."-ngs_Message_type-") WITH FUNCTION "SmallObjects"."cast_Message_to_type"("SmallObjects"."Message") AS IMPLICIT;
		CREATE CAST ("SmallObjects"."Message" AS text) WITH FUNCTION cast_to_text("SmallObjects"."Message") AS ASSIGNMENT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Message_type-' AND column_name = 'message') THEN
		ALTER TYPE "SmallObjects"."-ngs_Message_type-" ADD ATTRIBUTE "message" VARCHAR;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Message_type-"."message" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Message' AND column_name = 'message') THEN
		ALTER TYPE "SmallObjects"."Message" ADD ATTRIBUTE "message" VARCHAR;
		COMMENT ON COLUMN "SmallObjects"."Message"."message" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Message_type-' AND column_name = 'version') THEN
		ALTER TYPE "SmallObjects"."-ngs_Message_type-" ADD ATTRIBUTE "version" INT;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Message_type-"."version" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Message' AND column_name = 'version') THEN
		ALTER TYPE "SmallObjects"."Message" ADD ATTRIBUTE "version" INT;
		COMMENT ON COLUMN "SmallObjects"."Message"."version" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "StandardObjects"."cast_DeletePost_to_type"("StandardObjects"."DeletePost") RETURNS "StandardObjects"."-ngs_DeletePost_type-" AS $$ SELECT $1::text::"StandardObjects"."-ngs_DeletePost_type-" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION "StandardObjects"."cast_DeletePost_to_type"("StandardObjects"."-ngs_DeletePost_type-") RETURNS "StandardObjects"."DeletePost" AS $$ SELECT $1::text::"StandardObjects"."DeletePost" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION cast_to_text("StandardObjects"."DeletePost") RETURNS text AS $$ SELECT $1::VARCHAR $$ IMMUTABLE LANGUAGE sql COST 1;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'StandardObjects' AND s.typname = 'DeletePost' AND t.typname = '-ngs_DeletePost_type-') THEN
		CREATE CAST ("StandardObjects"."-ngs_DeletePost_type-" AS "StandardObjects"."DeletePost") WITH FUNCTION "StandardObjects"."cast_DeletePost_to_type"("StandardObjects"."-ngs_DeletePost_type-") AS IMPLICIT;
		CREATE CAST ("StandardObjects"."DeletePost" AS "StandardObjects"."-ngs_DeletePost_type-") WITH FUNCTION "StandardObjects"."cast_DeletePost_to_type"("StandardObjects"."DeletePost") AS IMPLICIT;
		CREATE CAST ("StandardObjects"."DeletePost" AS text) WITH FUNCTION cast_to_text("StandardObjects"."DeletePost") AS ASSIGNMENT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_DeletePost_type-' AND column_name = 'postID') THEN
		ALTER TYPE "StandardObjects"."-ngs_DeletePost_type-" ADD ATTRIBUTE "postID" INT;
		COMMENT ON COLUMN "StandardObjects"."-ngs_DeletePost_type-"."postID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'postID') THEN
		ALTER TYPE "StandardObjects"."DeletePost" ADD ATTRIBUTE "postID" INT;
		COMMENT ON COLUMN "StandardObjects"."DeletePost"."postID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_DeletePost_type-' AND column_name = 'lastModified') THEN
		ALTER TYPE "StandardObjects"."-ngs_DeletePost_type-" ADD ATTRIBUTE "lastModified" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."-ngs_DeletePost_type-"."lastModified" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'lastModified') THEN
		ALTER TYPE "StandardObjects"."DeletePost" ADD ATTRIBUTE "lastModified" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."DeletePost"."lastModified" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_DeletePost_type-' AND column_name = 'deletedBy') THEN
		ALTER TYPE "StandardObjects"."-ngs_DeletePost_type-" ADD ATTRIBUTE "deletedBy" BIGINT;
		COMMENT ON COLUMN "StandardObjects"."-ngs_DeletePost_type-"."deletedBy" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'deletedBy') THEN
		ALTER TYPE "StandardObjects"."DeletePost" ADD ATTRIBUTE "deletedBy" BIGINT;
		COMMENT ON COLUMN "StandardObjects"."DeletePost"."deletedBy" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_DeletePost_type-' AND column_name = 'reason') THEN
		ALTER TYPE "StandardObjects"."-ngs_DeletePost_type-" ADD ATTRIBUTE "reason" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."-ngs_DeletePost_type-"."reason" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'reason') THEN
		ALTER TYPE "StandardObjects"."DeletePost" ADD ATTRIBUTE "reason" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."DeletePost"."reason" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Footnote_type-' AND column_name = 'writtenBy') THEN
		ALTER TYPE "LargeObjects"."-ngs_Footnote_type-" ADD ATTRIBUTE "writtenBy" VARCHAR(100);
		COMMENT ON COLUMN "LargeObjects"."-ngs_Footnote_type-"."writtenBy" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Footnote' AND column_name = 'writtenBy') THEN
		ALTER TYPE "LargeObjects"."Footnote" ADD ATTRIBUTE "writtenBy" VARCHAR(100);
		COMMENT ON COLUMN "LargeObjects"."Footnote"."writtenBy" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Headnote_type-' AND column_name = 'writtenBy') THEN
		ALTER TYPE "LargeObjects"."-ngs_Headnote_type-" ADD ATTRIBUTE "writtenBy" VARCHAR(100);
		COMMENT ON COLUMN "LargeObjects"."-ngs_Headnote_type-"."writtenBy" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Headnote' AND column_name = 'writtenBy') THEN
		ALTER TYPE "LargeObjects"."Headnote" ADD ATTRIBUTE "writtenBy" VARCHAR(100);
		COMMENT ON COLUMN "LargeObjects"."Headnote"."writtenBy" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW "LargeObjects"."Page_entity" AS
SELECT "-NGS-".Generate_Uri2(CAST(_entity."BookID" as TEXT), CAST(_entity."Index" as TEXT)) AS "URI" , _entity."text", _entity."notes", _entity."identity", _entity."BookID", _entity."Index"
FROM
	"LargeObjects"."Page" _entity
	;
COMMENT ON VIEW "LargeObjects"."Page_entity" IS 'NGS volatile';

CREATE OR REPLACE VIEW "LargeObjects"."Book_entity" AS
SELECT CAST(_entity."ID" as TEXT) AS "URI" , _entity."ID", _entity."title", _entity."authorId", COALESCE((SELECT array_agg(sq ORDER BY sq."Index") FROM "LargeObjects"."Page_entity" sq WHERE sq."BookID" = _entity."ID"), '{}') AS "pages", _entity."published", _entity."cover", _entity."changes", _entity."metadata", _entity."genres"
FROM
	"LargeObjects"."Book" _entity
	;
COMMENT ON VIEW "LargeObjects"."Book_entity" IS 'NGS volatile';

CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."-ngs_Page_type-") RETURNS "LargeObjects"."Page_entity" AS $$ SELECT $1::text::"LargeObjects"."Page_entity" $$ IMMUTABLE LANGUAGE sql;
CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."Page_entity") RETURNS "LargeObjects"."-ngs_Page_type-" AS $$ SELECT $1::text::"LargeObjects"."-ngs_Page_type-" $$ IMMUTABLE LANGUAGE sql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'LargeObjects' AND s.typname = 'Page_entity' AND t.typname = '-ngs_Page_type-') THEN
		CREATE CAST ("LargeObjects"."-ngs_Page_type-" AS "LargeObjects"."Page_entity") WITH FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."-ngs_Page_type-") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Page_entity" AS "LargeObjects"."-ngs_Page_type-") WITH FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."Page_entity") AS IMPLICIT;
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Book_to_type"("LargeObjects"."-ngs_Book_type-") RETURNS "LargeObjects"."Book_entity" AS $$ SELECT $1::text::"LargeObjects"."Book_entity" $$ IMMUTABLE LANGUAGE sql;
CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Book_to_type"("LargeObjects"."Book_entity") RETURNS "LargeObjects"."-ngs_Book_type-" AS $$ SELECT $1::text::"LargeObjects"."-ngs_Book_type-" $$ IMMUTABLE LANGUAGE sql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'LargeObjects' AND s.typname = 'Book_entity' AND t.typname = '-ngs_Book_type-') THEN
		CREATE CAST ("LargeObjects"."-ngs_Book_type-" AS "LargeObjects"."Book_entity") WITH FUNCTION "LargeObjects"."cast_Book_to_type"("LargeObjects"."-ngs_Book_type-") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Book_entity" AS "LargeObjects"."-ngs_Book_type-") WITH FUNCTION "LargeObjects"."cast_Book_to_type"("LargeObjects"."Book_entity") AS IMPLICIT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '>tmp-Book-insert<' AND column_name = 'tuple') THEN
		DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-insert<";
	END IF;
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '>tmp-Book-update<' AND column_name = 'old') THEN
		DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-update<";
	END IF;
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '>tmp-Book-delete<' AND column_name = 'tuple') THEN
		DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-delete<";
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = '>tmp-Book-insert<') THEN
		CREATE UNLOGGED TABLE "LargeObjects".">tmp-Book-insert<" AS SELECT 0::int as i, t as tuple FROM "LargeObjects"."Book_entity" t LIMIT 0;
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = '>tmp-Book-update<') THEN
		CREATE UNLOGGED TABLE "LargeObjects".">tmp-Book-update<" AS SELECT 0::int as i, t as old, t as new FROM "LargeObjects"."Book_entity" t LIMIT 0;
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = '>tmp-Book-delete<') THEN
		CREATE UNLOGGED TABLE "LargeObjects".">tmp-Book-delete<" AS SELECT 0::int as i, t as tuple FROM "LargeObjects"."Book_entity" t LIMIT 0;
	END IF;

	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '>tmp-Book-insert764896781<' AND column_name = 'tuple') THEN
		DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-insert764896781<";
	END IF;
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '>tmp-Book-update764896781<' AND column_name = 'old') THEN
		DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-update764896781<";
	END IF;
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '>tmp-Book-delete764896781<' AND column_name = 'tuple') THEN
		DROP TABLE IF EXISTS "LargeObjects".">tmp-Book-delete764896781<";
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = '>tmp-Book-insert764896781<') THEN
		CREATE UNLOGGED TABLE "LargeObjects".">tmp-Book-insert764896781<" AS SELECT 0::int as i, 0::int as index, t as tuple FROM "LargeObjects"."Page_entity" t LIMIT 0;
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = '>tmp-Book-update764896781<') THEN
		CREATE UNLOGGED TABLE "LargeObjects".">tmp-Book-update764896781<" AS SELECT 0::int as i, 0::int as index, t as old, t as changed, t as new, true as is_new FROM "LargeObjects"."Page_entity" t LIMIT 0;
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = '>tmp-Book-delete764896781<') THEN
		CREATE UNLOGGED TABLE "LargeObjects".">tmp-Book-delete764896781<" AS SELECT 0::int as i, 0::int as index, t as tuple FROM "LargeObjects"."Page_entity" t LIMIT 0;
	END IF;
END $$ LANGUAGE plpgsql;

--TODO: temp fix for rename
DROP FUNCTION IF EXISTS "LargeObjects"."persist_Book_internal"(int, int);

CREATE OR REPLACE FUNCTION "LargeObjects"."persist_Book_internal"(_update_count int, _delete_count int) 
	RETURNS VARCHAR AS
$$
DECLARE cnt int;
DECLARE uri VARCHAR;
DECLARE tmp record;
DECLARE "_var_LargeObjects.Page" "LargeObjects"."Page_entity"[];
BEGIN

	SET CONSTRAINTS ALL DEFERRED;

	

	INSERT INTO "LargeObjects"."Book" ("ID", "title", "authorId", "published", "cover", "changes", "metadata", "genres")
	SELECT (tuple)."ID", (tuple)."title", (tuple)."authorId", (tuple)."published", (tuple)."cover", (tuple)."changes", (tuple)."metadata", (tuple)."genres" 
	FROM "LargeObjects".">tmp-Book-insert<" i;

	
	INSERT INTO "LargeObjects"."Page" ("text", "notes", "identity", "BookID", "Index")
	SELECT (tuple)."text", (tuple)."notes", (tuple)."identity", (tuple)."BookID", (tuple)."Index" 
	FROM "LargeObjects".">tmp-Book-insert764896781<" t;

		
	UPDATE "LargeObjects"."Book" as tbl SET 
		"ID" = (new)."ID", "title" = (new)."title", "authorId" = (new)."authorId", "published" = (new)."published", "cover" = (new)."cover", "changes" = (new)."changes", "metadata" = (new)."metadata", "genres" = (new)."genres"
	FROM "LargeObjects".">tmp-Book-update<" u
	WHERE
		tbl."ID" = (old)."ID";

	GET DIAGNOSTICS cnt = ROW_COUNT;
	IF cnt != _update_count THEN 
		RETURN 'Updated ' || cnt || ' row(s). Expected to update ' || _update_count || ' row(s).';
	END IF;

	
	DELETE FROM "LargeObjects"."Page" AS tbl
	WHERE 
		("BookID", "Index") IN (SELECT (u.old)."BookID", (u.old)."Index" FROM "LargeObjects".">tmp-Book-update764896781<" u WHERE NOT u.old IS NULL AND u.changed IS NULL);

	UPDATE "LargeObjects"."Page" AS tbl SET
		"text" = (u.changed)."text", "notes" = (u.changed)."notes", "identity" = (u.changed)."identity", "BookID" = (u.changed)."BookID", "Index" = (u.changed)."Index"
	FROM "LargeObjects".">tmp-Book-update764896781<" u
	WHERE
		NOT u.changed IS NULL
		AND NOT u.old IS NULL
		AND u.old != u.changed
		AND tbl."BookID" = (u.old)."BookID" AND tbl."Index" = (u.old)."Index" ;

	INSERT INTO "LargeObjects"."Page" ("text", "notes", "identity", "BookID", "Index")
	SELECT (new)."text", (new)."notes", (new)."identity", (new)."BookID", (new)."Index"
	FROM 
		"LargeObjects".">tmp-Book-update764896781<" u
	WHERE u.is_new;
	DELETE FROM "LargeObjects"."Page"	WHERE ("BookID", "Index") IN (SELECT (tuple)."BookID", (tuple)."Index" FROM "LargeObjects".">tmp-Book-delete764896781<" d);

	DELETE FROM "LargeObjects"."Book"
	WHERE ("ID") IN (SELECT (tuple)."ID" FROM "LargeObjects".">tmp-Book-delete<" d);

	GET DIAGNOSTICS cnt = ROW_COUNT;
	IF cnt != _delete_count THEN 
		RETURN 'Deleted ' || cnt || ' row(s). Expected to delete ' || _delete_count || ' row(s).';
	END IF;

	
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'LargeObjects.Book', 'Insert', (SELECT array_agg((tuple)."URI") FROM "LargeObjects".">tmp-Book-insert<"));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'LargeObjects.Book', 'Update', (SELECT array_agg((old)."URI") FROM "LargeObjects".">tmp-Book-update<"));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'LargeObjects.Book', 'Change', (SELECT array_agg((new)."URI") FROM "LargeObjects".">tmp-Book-update<" WHERE (old)."URI" != (new)."URI"));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'LargeObjects.Book', 'Delete', (SELECT array_agg((tuple)."URI") FROM "LargeObjects".">tmp-Book-delete<"));

	SET CONSTRAINTS ALL IMMEDIATE;

	
	DELETE FROM "LargeObjects".">tmp-Book-insert764896781<";
	DELETE FROM "LargeObjects".">tmp-Book-update764896781<";
	DELETE FROM "LargeObjects".">tmp-Book-delete764896781<";
	DELETE FROM "LargeObjects".">tmp-Book-insert<";
	DELETE FROM "LargeObjects".">tmp-Book-update<";
	DELETE FROM "LargeObjects".">tmp-Book-delete<";

	RETURN NULL;
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION "LargeObjects"."persist_Book"(
IN _inserted "LargeObjects"."Book_entity"[], IN _updated_original "LargeObjects"."Book_entity"[], IN _updated_new "LargeObjects"."Book_entity"[], IN _deleted "LargeObjects"."Book_entity"[]) 
	RETURNS VARCHAR AS
$$
DECLARE cnt int;
DECLARE uri VARCHAR;
DECLARE tmp record;
DECLARE "_var_LargeObjects.Page" "LargeObjects"."Page_entity"[];
BEGIN

	INSERT INTO "LargeObjects".">tmp-Book-insert<"
	SELECT i, _inserted[i]
	FROM generate_series(1, array_upper(_inserted, 1)) i;

	INSERT INTO "LargeObjects".">tmp-Book-update<"
	SELECT i, _updated_original[i], _updated_new[i]
	FROM generate_series(1, array_upper(_updated_new, 1)) i;

	INSERT INTO "LargeObjects".">tmp-Book-delete<"
	SELECT i, _deleted[i]
	FROM generate_series(1, array_upper(_deleted, 1)) i;

	
	FOR cnt, "_var_LargeObjects.Page" IN SELECT t.i, (t.tuple)."pages" AS children FROM "LargeObjects".">tmp-Book-insert<" t LOOP
		INSERT INTO "LargeObjects".">tmp-Book-insert764896781<"
		SELECT cnt, index, "_var_LargeObjects.Page"[index] from generate_series(1, array_upper("_var_LargeObjects.Page", 1)) index;
	END LOOP;

	INSERT INTO "LargeObjects".">tmp-Book-update764896781<"
	SELECT i, index, old[index] AS old, (select n from unnest(new) n where n."URI" = old[index]."URI") AS changed, new[index] AS new, not exists(select o from unnest(old) o where o."URI" = new[index]."URI") AND NOT new[index] IS NULL as is_new
	FROM 
		(
			SELECT 
				i, 
				(t.old)."pages" AS old,
				(t.new)."pages" AS new,
				unnest((SELECT array_agg(i) FROM generate_series(1, CASE WHEN coalesce(array_upper((t.old)."pages", 1), 0) > coalesce(array_upper((t.new)."pages", 1),0) THEN array_upper((t.old)."pages", 1) ELSE array_upper((t.new)."pages", 1) END) i)) as index 
			FROM "LargeObjects".">tmp-Book-update<" t
			WHERE 
				NOT (t.old)."pages" IS NULL AND (t.new)."pages" IS NULL
				OR (t.old)."pages" IS NULL AND NOT (t.new)."pages" IS NULL
				OR NOT (t.old)."pages" IS NULL AND NOT (t.new)."pages" IS NULL AND (t.old)."pages" != (t.new)."pages"
		) sq;

	FOR cnt, "_var_LargeObjects.Page" IN SELECT t.i, (t.tuple)."pages" AS children FROM "LargeObjects".">tmp-Book-delete<" t LOOP
		INSERT INTO "LargeObjects".">tmp-Book-delete764896781<"
		SELECT cnt, index, "_var_LargeObjects.Page"[index] from generate_series(1, array_upper("_var_LargeObjects.Page", 1)) index;
	END LOOP;

	RETURN "LargeObjects"."persist_Book_internal"(array_upper(_updated_new, 1), array_upper(_deleted, 1));
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE VIEW "LargeObjects"."Book_unprocessed_events" AS
SELECT _aggregate."ID"
FROM
	"LargeObjects"."Book_entity" _aggregate
;
COMMENT ON VIEW "LargeObjects"."Book_unprocessed_events" IS 'NGS volatile';

SELECT "-NGS-".Create_Type_Cast('"SmallObjects"."cast_Message_to_type"("SmallObjects"."-ngs_Message_type-")', 'SmallObjects', '-ngs_Message_type-', 'Message');
SELECT "-NGS-".Create_Type_Cast('"SmallObjects"."cast_Message_to_type"("SmallObjects"."Message")', 'SmallObjects', 'Message', '-ngs_Message_type-');

SELECT "-NGS-".Create_Type_Cast('"StandardObjects"."cast_DeletePost_to_type"("StandardObjects"."-ngs_DeletePost_type-")', 'StandardObjects', '-ngs_DeletePost_type-', 'DeletePost');
SELECT "-NGS-".Create_Type_Cast('"StandardObjects"."cast_DeletePost_to_type"("StandardObjects"."DeletePost")', 'StandardObjects', 'DeletePost', '-ngs_DeletePost_type-');

SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Page_to_type"("LargeObjects"."-ngs_Page_type-")', 'LargeObjects', '-ngs_Page_type-', 'Page_entity');
SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Page_to_type"("LargeObjects"."Page_entity")', 'LargeObjects', 'Page_entity', '-ngs_Page_type-');

SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Book_to_type"("LargeObjects"."-ngs_Book_type-")', 'LargeObjects', '-ngs_Book_type-', 'Book_entity');
SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Book_to_type"("LargeObjects"."Book_entity")', 'LargeObjects', 'Book_entity', '-ngs_Book_type-');
UPDATE "LargeObjects"."Book" SET "genres" = '{}' WHERE "genres" IS NULL;
ALTER TABLE "LargeObjects"."Book" ALTER "genres" SET NOT NULL;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_constraint c JOIN pg_class r ON c.conrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace WHERE c.conname = 'fk_pages' AND n.nspname = 'LargeObjects' AND r.relname = 'Page') THEN	
		ALTER TABLE "LargeObjects"."Page" 
			ADD CONSTRAINT "fk_pages"
				FOREIGN KEY ("BookID") REFERENCES "LargeObjects"."Book" ("ID")
				ON UPDATE CASCADE ON DELETE CASCADE;
		COMMENT ON CONSTRAINT "fk_pages" ON "LargeObjects"."Page" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

SELECT "-NGS-".Persist_Concepts('"LargeObjects.dsl"=>"module LargeObjects {
	root Book {
		string title;
		int authorId;
		linked list<Page> pages;
		date? published;
		binary? cover;
		Set<Date> changes;
		Map metadata;
		Array<Genre> genres;
	}
	enum Genre {
		Action;
		Romance;
		Comedy;
		SciFi;
	}
	entity Page {
		string text;
		List<Note> notes;
		guid identity;
	}
	value Footnote {
		has mixin Note;
		timestamp createadAt;
		long index;
	}
	value Headnote {
		has mixin Note;
		timestamp? modifiedAt;
	}
	mixin Note {
		string note;
		string(100)? writtenBy;
	}
}","SmallObjects.dsl"=>"module SmallObjects {
	value Message {
		string message;
		int version;
	}
	root Post {
		string title;
		string text;
		date created;
	}
	value Complex {
		decimal x;
		decimal y;
	}
}","StandardObjects.dsl"=>"module StandardObjects {
	value DeletePost {
		int postID;
		timestamp lastModified;
		long deletedBy;
		string? reason;
	}
	enum PostState {
		Draft;
		Published;
		Hidden;
	}
	root Post {
		string title;
		string text;
		date created;
		Set<string> tags;
		timestamp? approved;
		timestamp lastModified;
		List<Comment> comments;
		Vote votes;
		List<string>? notes;
		PostState state;
	}
	enum CommentState {
		Pending;
		Approved;
		Removed;
	}
	entity Comment {
		timestamp created;
		timestamp? approved;
		string? user;
		string message;
		Vote votes;
		CommentState state;
	}
	value Vote {
		int upvote;
		int downvote;
	}
}"', '\x','1.0.3.42920')