/*MIGRATION_DESCRIPTION
--CREATE: LargeObjects-Book
New object Book will be created in schema LargeObjects
--CREATE: LargeObjects-Book-ID
New property ID will be created for Book in LargeObjects
--CREATE: LargeObjects-Book-title
New property title will be created for Book in LargeObjects
--CREATE: LargeObjects-Book-authorId
New property authorId will be created for Book in LargeObjects
--CREATE: LargeObjects-Book-published
New property published will be created for Book in LargeObjects
--CREATE: LargeObjects-Book-frontCover
New property frontCover will be created for Book in LargeObjects
--CREATE: LargeObjects-Book-backCover
New property backCover will be created for Book in LargeObjects
--CREATE: LargeObjects-Book-changes
New property changes will be created for Book in LargeObjects
--CREATE: LargeObjects-Book-metadata
New property metadata will be created for Book in LargeObjects
--CREATE: LargeObjects-Page
New object Page will be created in schema LargeObjects
--CREATE: LargeObjects-Page-text
New property text will be created for Page in LargeObjects
--CREATE: LargeObjects-Page-notes
New property notes will be created for Page in LargeObjects
--CREATE: LargeObjects-Page-illustrations
New property illustrations will be created for Page in LargeObjects
--CREATE: LargeObjects-Page-identity
New property identity will be created for Page in LargeObjects
--CREATE: LargeObjects-Footnote
New object Footnote will be created in schema LargeObjects
--CREATE: LargeObjects-Note with LargeObjects-Footnote
Object Footnote from schema LargeObjects can be persisted as mixin in LargeObjects.Note
--CREATE: LargeObjects-Footnote-createadAt
New property createadAt will be created for Footnote in LargeObjects
--CREATE: LargeObjects-Footnote-index
New property index will be created for Footnote in LargeObjects
--CREATE: LargeObjects-Headnote
New object Headnote will be created in schema LargeObjects
--CREATE: LargeObjects-Note with LargeObjects-Headnote
Object Headnote from schema LargeObjects can be persisted as mixin in LargeObjects.Note
--CREATE: LargeObjects-Headnote-modifiedAt
New property modifiedAt will be created for Headnote in LargeObjects
--CREATE: LargeObjects-Note
New object Note will be created in schema LargeObjects
--CREATE: LargeObjects-Note-note
New property note will be created for Note in LargeObjects
--CREATE: SmallObjects-Message
New object Message will be created in schema SmallObjects
--CREATE: SmallObjects-Message-message
New property message will be created for Message in SmallObjects
--CREATE: SmallObjects-Post
New object Post will be created in schema SmallObjects
--CREATE: SmallObjects-Post-ID
New property ID will be created for Post in SmallObjects
--CREATE: SmallObjects-Post-title
New property title will be created for Post in SmallObjects
--CREATE: SmallObjects-Post-text
New property text will be created for Post in SmallObjects
--CREATE: SmallObjects-Post-created
New property created will be created for Post in SmallObjects
--CREATE: SmallObjects-Complex
New object Complex will be created in schema SmallObjects
--CREATE: SmallObjects-Complex-x
New property x will be created for Complex in SmallObjects
--CREATE: SmallObjects-Complex-y
New property y will be created for Complex in SmallObjects
--CREATE: StandardObjects-DeletePost
New object DeletePost will be created in schema StandardObjects
--CREATE: StandardObjects-DeletePost-post
New property post will be created for DeletePost in StandardObjects
--CREATE: StandardObjects-DeletePost-reason
New property reason will be created for DeletePost in StandardObjects
--CREATE: StandardObjects-PostState
New object PostState will be created in schema StandardObjects
--CREATE: StandardObjects-PostState-Draft
New enum label Draft will be added to enum object PostState in schema StandardObjects
--CREATE: StandardObjects-PostState-Published
New enum label Published will be added to enum object PostState in schema StandardObjects
--CREATE: StandardObjects-PostState-Hidden
New enum label Hidden will be added to enum object PostState in schema StandardObjects
--CREATE: StandardObjects-Post
New object Post will be created in schema StandardObjects
--CREATE: StandardObjects-Post-ID
New property ID will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-title
New property title will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-text
New property text will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-created
New property created will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-tags
New property tags will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-approved
New property approved will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-lastModified
New property lastModified will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-votes
New property votes will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-notes
New property notes will be created for Post in StandardObjects
--CREATE: StandardObjects-Post-state
New property state will be created for Post in StandardObjects
--CREATE: StandardObjects-CommentState
New object CommentState will be created in schema StandardObjects
--CREATE: StandardObjects-CommentState-Pending
New enum label Pending will be added to enum object CommentState in schema StandardObjects
--CREATE: StandardObjects-CommentState-Approved
New enum label Approved will be added to enum object CommentState in schema StandardObjects
--CREATE: StandardObjects-CommentState-Removed
New enum label Removed will be added to enum object CommentState in schema StandardObjects
--CREATE: StandardObjects-Comment
New object Comment will be created in schema StandardObjects
--CREATE: StandardObjects-Comment-created
New property created will be created for Comment in StandardObjects
--CREATE: StandardObjects-Comment-approved
New property approved will be created for Comment in StandardObjects
--CREATE: StandardObjects-Comment-user
New property user will be created for Comment in StandardObjects
--CREATE: StandardObjects-Comment-message
New property message will be created for Comment in StandardObjects
--CREATE: StandardObjects-Comment-votes
New property votes will be created for Comment in StandardObjects
--CREATE: StandardObjects-Comment-state
New property state will be created for Comment in StandardObjects
--CREATE: StandardObjects-Vote
New object Vote will be created in schema StandardObjects
--CREATE: StandardObjects-Vote-upvote
New property upvote will be created for Vote in StandardObjects
--CREATE: StandardObjects-Vote-downvote
New property downvote will be created for Vote in StandardObjects
--CREATE: LargeObjects-Page-BookID
New property BookID will be created for Page in LargeObjects
--CREATE: LargeObjects-Page-Index
New property Index will be created for Page in LargeObjects
--CREATE: StandardObjects-Comment-PostID
New property PostID will be created for Comment in StandardObjects
--CREATE: StandardObjects-Comment-Index
New property Index will be created for Comment in StandardObjects
--CREATE: LargeObjects-Footnote-note
New property note will be created for Footnote in LargeObjects
--CREATE: LargeObjects-Headnote-note
New property note will be created for Headnote in LargeObjects
MIGRATION_DESCRIPTION*/

DO $$ BEGIN
	IF EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = '-NGS-' AND c.relname = 'database_setting') THEN	
		IF EXISTS(SELECT * FROM "-NGS-".Database_Setting WHERE Key ILIKE 'mode' AND NOT Value ILIKE 'unsafe') THEN
			RAISE EXCEPTION 'Database upgrade is forbidden. Change database mode to allow upgrade';
		END IF;
	END IF;
END $$ LANGUAGE plpgsql;
CREATE EXTENSION IF NOT EXISTS hstore;

DO $$
DECLARE script VARCHAR;
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_namespace WHERE nspname = '-NGS-') THEN
		CREATE SCHEMA "-NGS-";
		COMMENT ON SCHEMA "-NGS-" IS 'NGS generated';
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_namespace WHERE nspname = 'public') THEN
		CREATE SCHEMA public;
		COMMENT ON SCHEMA public IS 'NGS generated';
	END IF;
	SELECT array_to_string(array_agg('DROP VIEW IF EXISTS ' || quote_ident(n.nspname) || '.' || quote_ident(cl.relname) || ' CASCADE;'), '')
	INTO script
	FROM pg_class cl
	INNER JOIN pg_namespace n ON cl.relnamespace = n.oid
	INNER JOIN pg_description d ON d.objoid = cl.oid
	WHERE cl.relkind = 'v' AND d.description LIKE 'NGS volatile%';
	IF length(script) > 0 THEN
		EXECUTE script;
	END IF;
END $$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS "-NGS-".Database_Migration
(
	Ordinal SERIAL PRIMARY KEY,
	Dsls TEXT,
	Implementations BYTEA,
	Version VARCHAR,
	Applied_At TIMESTAMPTZ DEFAULT (CURRENT_TIMESTAMP)
);

CREATE OR REPLACE FUNCTION "-NGS-".Load_Last_Migration()
RETURNS "-NGS-".Database_Migration AS
$$
SELECT m FROM "-NGS-".Database_Migration m
ORDER BY Ordinal DESC 
LIMIT 1
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION "-NGS-".Persist_Concepts(dsls TEXT, implementations BYTEA, version VARCHAR)
  RETURNS void AS
$$
BEGIN
	INSERT INTO "-NGS-".Database_Migration(Dsls, Implementations, Version) VALUES(dsls, implementations, version);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION "-NGS-".Generate_Uri2(text, text) RETURNS text AS 
$$
BEGIN
	RETURN replace(replace($1, '\','\\'), '/', '\/')||'/'||replace(replace($2, '\','\\'), '/', '\/');
END;
$$ LANGUAGE PLPGSQL IMMUTABLE;

CREATE OR REPLACE FUNCTION "-NGS-".Generate_Uri3(text, text, text) RETURNS text AS 
$$
BEGIN
	RETURN replace(replace($1, '\','\\'), '/', '\/')||'/'||replace(replace($2, '\','\\'), '/', '\/')||'/'||replace(replace($3, '\','\\'), '/', '\/');
END;
$$ LANGUAGE PLPGSQL IMMUTABLE;

CREATE OR REPLACE FUNCTION "-NGS-".Generate_Uri4(text, text, text, text) RETURNS text AS 
$$
BEGIN
	RETURN replace(replace($1, '\','\\'), '/', '\/')||'/'||replace(replace($2, '\','\\'), '/', '\/')||'/'||replace(replace($3, '\','\\'), '/', '\/')||'/'||replace(replace($4, '\','\\'), '/', '\/');
END;
$$ LANGUAGE PLPGSQL IMMUTABLE;

CREATE OR REPLACE FUNCTION "-NGS-".Generate_Uri5(text, text, text, text, text) RETURNS text AS 
$$
BEGIN
	RETURN replace(replace($1, '\','\\'), '/', '\/')||'/'||replace(replace($2, '\','\\'), '/', '\/')||'/'||replace(replace($3, '\','\\'), '/', '\/')||'/'||replace(replace($4, '\','\\'), '/', '\/')||'/'||replace(replace($5, '\','\\'), '/', '\/');
END;
$$ LANGUAGE PLPGSQL IMMUTABLE;

CREATE OR REPLACE FUNCTION "-NGS-".Generate_Uri(text[]) RETURNS text AS 
$$
BEGIN
	RETURN (SELECT array_to_string(array_agg(replace(replace(u, '\','\\'), '/', '\/')), '/') FROM unnest($1) u);
END;
$$ LANGUAGE PLPGSQL IMMUTABLE;

CREATE OR REPLACE FUNCTION "-NGS-".Safe_Notify(target varchar, name varchar, operation varchar, uris varchar[]) RETURNS VOID AS
$$
DECLARE message VARCHAR;
DECLARE array_size INT;
BEGIN
	array_size = array_upper(uris, 1);
	message = name || ':' || operation || ':' || uris::TEXT;
	IF (array_size > 0 and length(message) < 8000) THEN 
		PERFORM pg_notify(target, message);
	ELSEIF (array_size > 1) THEN
		PERFORM "-NGS-".Safe_Notify(target, name, operation, (SELECT array_agg(uris[i]) FROM generate_series(1, (array_size+1)/2) i));
		PERFORM "-NGS-".Safe_Notify(target, name, operation, (SELECT array_agg(uris[i]) FROM generate_series(array_size/2+1, array_size) i));
	ELSEIF (array_size = 1) THEN
		RAISE EXCEPTION 'uri can''t be longer than 8000 characters';
	END IF;	
END
$$ LANGUAGE PLPGSQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION "-NGS-".Split_Uri(s text) RETURNS TEXT[] AS
$$
DECLARE i int;
DECLARE pos int;
DECLARE len int;
DECLARE res TEXT[];
DECLARE cur TEXT;
DECLARE c CHAR(1);
BEGIN
	pos = 0;
	i = 1;
	cur = '';
	len = length(s);
	LOOP
		pos = pos + 1;
		EXIT WHEN pos > len;
		c = substr(s, pos, 1);
		IF c = '/' THEN
			res[i] = cur;
			i = i + 1;
			cur = '';
		ELSE
			IF c = '\' THEN
				pos = pos + 1;
				c = substr(s, pos, 1);
			END IF;		
			cur = cur || c;
		END IF;
	END LOOP;
	res[i] = cur;
	return res;
END
$$ LANGUAGE plpgsql SECURITY DEFINER IMMUTABLE;

CREATE OR REPLACE FUNCTION "-NGS-".Load_Type_Info(
	OUT type_schema character varying, 
	OUT type_name character varying, 
	OUT column_name character varying, 
	OUT column_schema character varying,
	OUT column_type character varying, 
	OUT column_index smallint, 
	OUT is_not_null boolean,
	OUT is_ngs_generated boolean)
  RETURNS SETOF record AS
$BODY$
SELECT 
	ns.nspname::varchar, 
	cl.relname::varchar, 
	atr.attname::varchar, 
	ns_ref.nspname::varchar,
	typ.typname::varchar, 
	(SELECT COUNT(*) + 1
	FROM pg_attribute atr_ord
	WHERE 
		atr.attrelid = atr_ord.attrelid
		AND atr_ord.attisdropped = false
		AND atr_ord.attnum > 0
		AND atr_ord.attnum < atr.attnum)::smallint, 
	atr.attnotnull,
	coalesce(d.description LIKE 'NGS generated%', false)
FROM 
	pg_attribute atr
	INNER JOIN pg_class cl ON atr.attrelid = cl.oid
	INNER JOIN pg_namespace ns ON cl.relnamespace = ns.oid
	INNER JOIN pg_type typ ON atr.atttypid = typ.oid
	INNER JOIN pg_namespace ns_ref ON typ.typnamespace = ns_ref.oid
	LEFT JOIN pg_description d ON d.objoid = cl.oid
								AND d.objsubid = atr.attnum
WHERE
	(cl.relkind = 'r' OR cl.relkind = 'v' OR cl.relkind = 'c')
	AND ns.nspname NOT LIKE 'pg_%'
	AND ns.nspname != 'information_schema'
	AND atr.attnum > 0
	AND atr.attisdropped = FALSE
ORDER BY 1, 2, 6
$BODY$
  LANGUAGE SQL STABLE;

CREATE TABLE IF NOT EXISTS "-NGS-".Database_Setting
(
	Key VARCHAR PRIMARY KEY,
	Value TEXT NOT NULL
);

CREATE OR REPLACE FUNCTION "-NGS-".Create_Type_Cast(function VARCHAR, schema VARCHAR, from_name VARCHAR, to_name VARCHAR)
RETURNS void
AS
$$
DECLARE header VARCHAR;
DECLARE source VARCHAR;
DECLARE footer VARCHAR;
DECLARE col_name VARCHAR;
DECLARE type VARCHAR = '"' || schema || '"."' || to_name || '"';
BEGIN
	header = 'CREATE OR REPLACE FUNCTION ' || function || '
RETURNS ' || type || '
AS
$BODY$
SELECT ROW(';
	footer = ')::' || type || '
$BODY$ IMMUTABLE LANGUAGE sql;';
	source = '';
	FOR col_name IN 
		SELECT 
			CASE WHEN 
				EXISTS (SELECT * FROM "-NGS-".Load_Type_Info() f 
					WHERE f.type_schema = schema AND f.type_name = from_name AND f.column_name = t.column_name)
				OR EXISTS(SELECT * FROM pg_proc p JOIN pg_type t_in ON p.proargtypes[0] = t_in.oid 
					JOIN pg_namespace n_in ON t_in.typnamespace = n_in.oid JOIN pg_namespace n ON p.pronamespace = n.oid
					WHERE array_upper(p.proargtypes, 1) = 0 AND n.nspname = 'public' AND t_in.typname = from_name AND p.proname = t.column_name) THEN t.column_name
				ELSE null
			END
		FROM "-NGS-".Load_Type_Info() t
		WHERE 
			t.type_schema = schema 
			AND t.type_name = to_name
		ORDER BY t.column_index 
	LOOP
		IF col_name IS NULL THEN
			source = source || 'null, ';
		ELSE
			source = source || '$1."' || col_name || '", ';
		END IF;
	END LOOP;
	IF (LENGTH(source) > 0) THEN 
		source = SUBSTRING(source, 1, LENGTH(source) - 2);
	END IF;
	EXECUTE (header || source || footer);
END
$$ LANGUAGE plpgsql;;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_extension e WHERE e.extname = 'hstore') THEN	
		CREATE EXTENSION hstore;
		COMMENT ON EXTENSION hstore IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_namespace WHERE nspname = 'LargeObjects') THEN
		CREATE SCHEMA "LargeObjects";
		COMMENT ON SCHEMA "LargeObjects" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_namespace WHERE nspname = 'SmallObjects') THEN
		CREATE SCHEMA "SmallObjects";
		COMMENT ON SCHEMA "SmallObjects" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_namespace WHERE nspname = 'StandardObjects') THEN
		CREATE SCHEMA "StandardObjects";
		COMMENT ON SCHEMA "StandardObjects" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = '-ngs_Book_type-') THEN	
		CREATE TYPE "LargeObjects"."-ngs_Book_type-" AS ();
		COMMENT ON TYPE "LargeObjects"."-ngs_Book_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = 'Book') THEN	
		CREATE TABLE "LargeObjects"."Book" ();
		COMMENT ON TABLE "LargeObjects"."Book" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = 'Book_sequence') THEN
		CREATE SEQUENCE "LargeObjects"."Book_sequence";
		COMMENT ON SEQUENCE "LargeObjects"."Book_sequence" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = '-ngs_Page_type-') THEN	
		CREATE TYPE "LargeObjects"."-ngs_Page_type-" AS ();
		COMMENT ON TYPE "LargeObjects"."-ngs_Page_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'LargeObjects' AND c.relname = 'Page') THEN	
		CREATE TABLE "LargeObjects"."Page" ();
		COMMENT ON TABLE "LargeObjects"."Page" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = '-ngs_Footnote_type-') THEN	
		CREATE TYPE "LargeObjects"."-ngs_Footnote_type-" AS ();
		COMMENT ON TYPE "LargeObjects"."-ngs_Footnote_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = 'Footnote') THEN	
		CREATE TYPE "LargeObjects"."Footnote" AS ();
		COMMENT ON TYPE "LargeObjects"."Footnote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = '-ngs_Headnote_type-') THEN	
		CREATE TYPE "LargeObjects"."-ngs_Headnote_type-" AS ();
		COMMENT ON TYPE "LargeObjects"."-ngs_Headnote_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = 'Headnote') THEN	
		CREATE TYPE "LargeObjects"."Headnote" AS ();
		COMMENT ON TYPE "LargeObjects"."Headnote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = 'Note') THEN	
		CREATE TYPE "LargeObjects"."Note" AS ();
		COMMENT ON TYPE "LargeObjects"."Note" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'LargeObjects' AND t.typname = '-ngs_Note_type-') THEN	
		CREATE TYPE "LargeObjects"."-ngs_Note_type-" AS ();
		COMMENT ON TYPE "LargeObjects"."-ngs_Note_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'SmallObjects' AND c.relname = 'Message') THEN	
		CREATE TABLE "SmallObjects"."Message" 
		(
			event_id BIGSERIAL PRIMARY KEY,
			queued_at TIMESTAMPTZ NOT NULL DEFAULT(NOW()),
			processed_at TIMESTAMPTZ
		);
		COMMENT ON TABLE "SmallObjects"."Message" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'SmallObjects' AND t.typname = '-ngs_Post_type-') THEN	
		CREATE TYPE "SmallObjects"."-ngs_Post_type-" AS ();
		COMMENT ON TYPE "SmallObjects"."-ngs_Post_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'SmallObjects' AND c.relname = 'Post') THEN	
		CREATE TABLE "SmallObjects"."Post" ();
		COMMENT ON TABLE "SmallObjects"."Post" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'SmallObjects' AND c.relname = 'Post_sequence') THEN
		CREATE SEQUENCE "SmallObjects"."Post_sequence";
		COMMENT ON SEQUENCE "SmallObjects"."Post_sequence" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'SmallObjects' AND t.typname = '-ngs_Complex_type-') THEN	
		CREATE TYPE "SmallObjects"."-ngs_Complex_type-" AS ();
		COMMENT ON TYPE "SmallObjects"."-ngs_Complex_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'SmallObjects' AND t.typname = 'Complex') THEN	
		CREATE TYPE "SmallObjects"."Complex" AS ();
		COMMENT ON TYPE "SmallObjects"."Complex" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = 'DeletePost') THEN	
		CREATE TABLE "StandardObjects"."DeletePost" 
		(
			event_id BIGSERIAL PRIMARY KEY,
			queued_at TIMESTAMPTZ NOT NULL DEFAULT(NOW()),
			processed_at TIMESTAMPTZ
		);
		COMMENT ON TABLE "StandardObjects"."DeletePost" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'PostState') THEN	
		CREATE TYPE "StandardObjects"."PostState" AS ENUM ('Draft', 'Published', 'Hidden');
		COMMENT ON TYPE "StandardObjects"."PostState" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = '-ngs_Post_type-') THEN	
		CREATE TYPE "StandardObjects"."-ngs_Post_type-" AS ();
		COMMENT ON TYPE "StandardObjects"."-ngs_Post_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = 'Post') THEN	
		CREATE TABLE "StandardObjects"."Post" ();
		COMMENT ON TABLE "StandardObjects"."Post" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = 'Post_sequence') THEN
		CREATE SEQUENCE "StandardObjects"."Post_sequence";
		COMMENT ON SEQUENCE "StandardObjects"."Post_sequence" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'CommentState') THEN	
		CREATE TYPE "StandardObjects"."CommentState" AS ENUM ('Pending', 'Approved', 'Removed');
		COMMENT ON TYPE "StandardObjects"."CommentState" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = '-ngs_Comment_type-') THEN	
		CREATE TYPE "StandardObjects"."-ngs_Comment_type-" AS ();
		COMMENT ON TYPE "StandardObjects"."-ngs_Comment_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = 'Comment') THEN	
		CREATE TABLE "StandardObjects"."Comment" ();
		COMMENT ON TABLE "StandardObjects"."Comment" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = '-ngs_Vote_type-') THEN	
		CREATE TYPE "StandardObjects"."-ngs_Vote_type-" AS ();
		COMMENT ON TYPE "StandardObjects"."-ngs_Vote_type-" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'Vote') THEN	
		CREATE TYPE "StandardObjects"."Vote" AS ();
		COMMENT ON TYPE "StandardObjects"."Vote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'URI') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "URI" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."URI" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'ID') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "ID" INT;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."ID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'ID') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "ID" INT;
		COMMENT ON COLUMN "LargeObjects"."Book"."ID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'title') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "title" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."title" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'title') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "title" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."Book"."title" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'authorId') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "authorId" INT;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."authorId" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'authorId') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "authorId" INT;
		COMMENT ON COLUMN "LargeObjects"."Book"."authorId" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'pagesURI') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "pagesURI" VARCHAR[];
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."pagesURI" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'published') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "published" DATE;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."published" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'published') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "published" DATE;
		COMMENT ON COLUMN "LargeObjects"."Book"."published" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'frontCover') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "frontCover" BYTEA;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."frontCover" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'frontCover') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "frontCover" BYTEA;
		COMMENT ON COLUMN "LargeObjects"."Book"."frontCover" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'backCover') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "backCover" BYTEA;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."backCover" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'backCover') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "backCover" BYTEA;
		COMMENT ON COLUMN "LargeObjects"."Book"."backCover" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'changes') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "changes" DATE[];
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."changes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'changes') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "changes" DATE[];
		COMMENT ON COLUMN "LargeObjects"."Book"."changes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'metadata') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "metadata" HSTORE;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."metadata" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Book' AND column_name = 'metadata') THEN
		ALTER TABLE "LargeObjects"."Book" ADD COLUMN "metadata" HSTORE;
		COMMENT ON COLUMN "LargeObjects"."Book"."metadata" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Page_type-' AND column_name = 'URI') THEN
		ALTER TYPE "LargeObjects"."-ngs_Page_type-" ADD ATTRIBUTE "URI" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Page_type-"."URI" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Page_type-' AND column_name = 'text') THEN
		ALTER TYPE "LargeObjects"."-ngs_Page_type-" ADD ATTRIBUTE "text" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Page_type-"."text" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Page' AND column_name = 'text') THEN
		ALTER TABLE "LargeObjects"."Page" ADD COLUMN "text" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."Page"."text" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Page_type-' AND column_name = 'notes') THEN
		ALTER TYPE "LargeObjects"."-ngs_Page_type-" ADD ATTRIBUTE "notes" "LargeObjects"."-ngs_Note_type-"[];
		COMMENT ON COLUMN "LargeObjects"."-ngs_Page_type-"."notes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Page' AND column_name = 'notes') THEN
		ALTER TABLE "LargeObjects"."Page" ADD COLUMN "notes" "LargeObjects"."Note"[];
		COMMENT ON COLUMN "LargeObjects"."Page"."notes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Page_type-' AND column_name = 'illustrations') THEN
		ALTER TYPE "LargeObjects"."-ngs_Page_type-" ADD ATTRIBUTE "illustrations" BYTEA[];
		COMMENT ON COLUMN "LargeObjects"."-ngs_Page_type-"."illustrations" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Page' AND column_name = 'illustrations') THEN
		ALTER TABLE "LargeObjects"."Page" ADD COLUMN "illustrations" BYTEA[];
		COMMENT ON COLUMN "LargeObjects"."Page"."illustrations" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Page_type-' AND column_name = 'identity') THEN
		ALTER TYPE "LargeObjects"."-ngs_Page_type-" ADD ATTRIBUTE "identity" UUID;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Page_type-"."identity" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Page' AND column_name = 'identity') THEN
		ALTER TABLE "LargeObjects"."Page" ADD COLUMN "identity" UUID;
		COMMENT ON COLUMN "LargeObjects"."Page"."identity" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Footnote_to_type"("LargeObjects"."Footnote") RETURNS "LargeObjects"."-ngs_Footnote_type-" AS $$ SELECT $1::text::"LargeObjects"."-ngs_Footnote_type-" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Footnote_to_type"("LargeObjects"."-ngs_Footnote_type-") RETURNS "LargeObjects"."Footnote" AS $$ SELECT $1::text::"LargeObjects"."Footnote" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION cast_to_text("LargeObjects"."Footnote") RETURNS text AS $$ SELECT $1::VARCHAR $$ IMMUTABLE LANGUAGE sql COST 1;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'LargeObjects' AND s.typname = 'Footnote' AND t.typname = '-ngs_Footnote_type-') THEN
		CREATE CAST ("LargeObjects"."-ngs_Footnote_type-" AS "LargeObjects"."Footnote") WITH FUNCTION "LargeObjects"."cast_Footnote_to_type"("LargeObjects"."-ngs_Footnote_type-") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Footnote" AS "LargeObjects"."-ngs_Footnote_type-") WITH FUNCTION "LargeObjects"."cast_Footnote_to_type"("LargeObjects"."Footnote") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Footnote" AS text) WITH FUNCTION cast_to_text("LargeObjects"."Footnote") AS ASSIGNMENT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Note_type-' AND column_name = 'LargeObjects.Footnote') THEN
		ALTER TYPE "LargeObjects"."-ngs_Note_type-" ADD ATTRIBUTE "LargeObjects.Footnote" "LargeObjects"."-ngs_Footnote_type-";
		COMMENT ON COLUMN "LargeObjects"."-ngs_Note_type-"."LargeObjects.Footnote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Note' AND column_name = 'LargeObjects.Footnote') THEN
		ALTER TYPE "LargeObjects"."Note" ADD ATTRIBUTE "LargeObjects.Footnote" "LargeObjects"."Footnote";
		COMMENT ON COLUMN "LargeObjects"."Note"."LargeObjects.Footnote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Footnote_type-' AND column_name = 'createadAt') THEN
		ALTER TYPE "LargeObjects"."-ngs_Footnote_type-" ADD ATTRIBUTE "createadAt" TIMESTAMPTZ;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Footnote_type-"."createadAt" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Footnote' AND column_name = 'createadAt') THEN
		ALTER TYPE "LargeObjects"."Footnote" ADD ATTRIBUTE "createadAt" TIMESTAMPTZ;
		COMMENT ON COLUMN "LargeObjects"."Footnote"."createadAt" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Footnote_type-' AND column_name = 'index') THEN
		ALTER TYPE "LargeObjects"."-ngs_Footnote_type-" ADD ATTRIBUTE "index" BIGINT;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Footnote_type-"."index" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Footnote' AND column_name = 'index') THEN
		ALTER TYPE "LargeObjects"."Footnote" ADD ATTRIBUTE "index" BIGINT;
		COMMENT ON COLUMN "LargeObjects"."Footnote"."index" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Headnote_to_type"("LargeObjects"."Headnote") RETURNS "LargeObjects"."-ngs_Headnote_type-" AS $$ SELECT $1::text::"LargeObjects"."-ngs_Headnote_type-" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Headnote_to_type"("LargeObjects"."-ngs_Headnote_type-") RETURNS "LargeObjects"."Headnote" AS $$ SELECT $1::text::"LargeObjects"."Headnote" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION cast_to_text("LargeObjects"."Headnote") RETURNS text AS $$ SELECT $1::VARCHAR $$ IMMUTABLE LANGUAGE sql COST 1;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'LargeObjects' AND s.typname = 'Headnote' AND t.typname = '-ngs_Headnote_type-') THEN
		CREATE CAST ("LargeObjects"."-ngs_Headnote_type-" AS "LargeObjects"."Headnote") WITH FUNCTION "LargeObjects"."cast_Headnote_to_type"("LargeObjects"."-ngs_Headnote_type-") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Headnote" AS "LargeObjects"."-ngs_Headnote_type-") WITH FUNCTION "LargeObjects"."cast_Headnote_to_type"("LargeObjects"."Headnote") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Headnote" AS text) WITH FUNCTION cast_to_text("LargeObjects"."Headnote") AS ASSIGNMENT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Note_type-' AND column_name = 'LargeObjects.Headnote') THEN
		ALTER TYPE "LargeObjects"."-ngs_Note_type-" ADD ATTRIBUTE "LargeObjects.Headnote" "LargeObjects"."-ngs_Headnote_type-";
		COMMENT ON COLUMN "LargeObjects"."-ngs_Note_type-"."LargeObjects.Headnote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Note' AND column_name = 'LargeObjects.Headnote') THEN
		ALTER TYPE "LargeObjects"."Note" ADD ATTRIBUTE "LargeObjects.Headnote" "LargeObjects"."Headnote";
		COMMENT ON COLUMN "LargeObjects"."Note"."LargeObjects.Headnote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Headnote_type-' AND column_name = 'modifiedAt') THEN
		ALTER TYPE "LargeObjects"."-ngs_Headnote_type-" ADD ATTRIBUTE "modifiedAt" TIMESTAMPTZ;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Headnote_type-"."modifiedAt" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Headnote' AND column_name = 'modifiedAt') THEN
		ALTER TYPE "LargeObjects"."Headnote" ADD ATTRIBUTE "modifiedAt" TIMESTAMPTZ;
		COMMENT ON COLUMN "LargeObjects"."Headnote"."modifiedAt" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Note_to_type"("LargeObjects"."Note") RETURNS "LargeObjects"."-ngs_Note_type-" AS $$ SELECT $1::text::"LargeObjects"."-ngs_Note_type-" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Note_to_type"("LargeObjects"."-ngs_Note_type-") RETURNS "LargeObjects"."Note" AS $$ SELECT $1::text::"LargeObjects"."Note" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION cast_to_text("LargeObjects"."Note") RETURNS text AS $$ SELECT $1::VARCHAR $$ IMMUTABLE LANGUAGE sql COST 1;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'LargeObjects' AND s.typname = 'Note' AND t.typname = '-ngs_Note_type-') THEN
		CREATE CAST ("LargeObjects"."-ngs_Note_type-" AS "LargeObjects"."Note") WITH FUNCTION "LargeObjects"."cast_Note_to_type"("LargeObjects"."-ngs_Note_type-") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Note" AS "LargeObjects"."-ngs_Note_type-") WITH FUNCTION "LargeObjects"."cast_Note_to_type"("LargeObjects"."Note") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Note" AS text) WITH FUNCTION cast_to_text("LargeObjects"."Note") AS ASSIGNMENT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Note_type-' AND column_name = 'note') THEN
		ALTER TYPE "LargeObjects"."-ngs_Note_type-" ADD ATTRIBUTE "note" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Note_type-"."note" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Note' AND column_name = 'note') THEN
		ALTER TYPE "LargeObjects"."Note" ADD ATTRIBUTE "note" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."Note"."note" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Message' AND column_name = 'message') THEN
		ALTER TABLE "SmallObjects"."Message" ADD COLUMN "message" VARCHAR;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'URI') THEN
		ALTER TYPE "SmallObjects"."-ngs_Post_type-" ADD ATTRIBUTE "URI" VARCHAR;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Post_type-"."URI" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'ID') THEN
		ALTER TYPE "SmallObjects"."-ngs_Post_type-" ADD ATTRIBUTE "ID" INT;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Post_type-"."ID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Post' AND column_name = 'ID') THEN
		ALTER TABLE "SmallObjects"."Post" ADD COLUMN "ID" INT;
		COMMENT ON COLUMN "SmallObjects"."Post"."ID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'title') THEN
		ALTER TYPE "SmallObjects"."-ngs_Post_type-" ADD ATTRIBUTE "title" VARCHAR;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Post_type-"."title" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Post' AND column_name = 'title') THEN
		ALTER TABLE "SmallObjects"."Post" ADD COLUMN "title" VARCHAR;
		COMMENT ON COLUMN "SmallObjects"."Post"."title" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'text') THEN
		ALTER TYPE "SmallObjects"."-ngs_Post_type-" ADD ATTRIBUTE "text" VARCHAR;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Post_type-"."text" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Post' AND column_name = 'text') THEN
		ALTER TABLE "SmallObjects"."Post" ADD COLUMN "text" VARCHAR;
		COMMENT ON COLUMN "SmallObjects"."Post"."text" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'created') THEN
		ALTER TYPE "SmallObjects"."-ngs_Post_type-" ADD ATTRIBUTE "created" DATE;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Post_type-"."created" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Post' AND column_name = 'created') THEN
		ALTER TABLE "SmallObjects"."Post" ADD COLUMN "created" DATE;
		COMMENT ON COLUMN "SmallObjects"."Post"."created" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "SmallObjects"."cast_Complex_to_type"("SmallObjects"."Complex") RETURNS "SmallObjects"."-ngs_Complex_type-" AS $$ SELECT $1::text::"SmallObjects"."-ngs_Complex_type-" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION "SmallObjects"."cast_Complex_to_type"("SmallObjects"."-ngs_Complex_type-") RETURNS "SmallObjects"."Complex" AS $$ SELECT $1::text::"SmallObjects"."Complex" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION cast_to_text("SmallObjects"."Complex") RETURNS text AS $$ SELECT $1::VARCHAR $$ IMMUTABLE LANGUAGE sql COST 1;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'SmallObjects' AND s.typname = 'Complex' AND t.typname = '-ngs_Complex_type-') THEN
		CREATE CAST ("SmallObjects"."-ngs_Complex_type-" AS "SmallObjects"."Complex") WITH FUNCTION "SmallObjects"."cast_Complex_to_type"("SmallObjects"."-ngs_Complex_type-") AS IMPLICIT;
		CREATE CAST ("SmallObjects"."Complex" AS "SmallObjects"."-ngs_Complex_type-") WITH FUNCTION "SmallObjects"."cast_Complex_to_type"("SmallObjects"."Complex") AS IMPLICIT;
		CREATE CAST ("SmallObjects"."Complex" AS text) WITH FUNCTION cast_to_text("SmallObjects"."Complex") AS ASSIGNMENT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Complex_type-' AND column_name = 'x') THEN
		ALTER TYPE "SmallObjects"."-ngs_Complex_type-" ADD ATTRIBUTE "x" NUMERIC;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Complex_type-"."x" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Complex' AND column_name = 'x') THEN
		ALTER TYPE "SmallObjects"."Complex" ADD ATTRIBUTE "x" NUMERIC;
		COMMENT ON COLUMN "SmallObjects"."Complex"."x" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Complex_type-' AND column_name = 'y') THEN
		ALTER TYPE "SmallObjects"."-ngs_Complex_type-" ADD ATTRIBUTE "y" NUMERIC;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Complex_type-"."y" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Complex' AND column_name = 'y') THEN
		ALTER TYPE "SmallObjects"."Complex" ADD ATTRIBUTE "y" NUMERIC;
		COMMENT ON COLUMN "SmallObjects"."Complex"."y" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'post') THEN
		ALTER TABLE "StandardObjects"."DeletePost" ADD COLUMN "post" "StandardObjects"."-ngs_Post_type-";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'reason') THEN
		ALTER TABLE "StandardObjects"."DeletePost" ADD COLUMN "reason" VARCHAR;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'PostState' AND e.enumlabel = 'Draft') THEN
		--ALTER TYPE "StandardObjects"."PostState" ADD VALUE IF NOT EXISTS 'Draft'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Draft', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'StandardObjects' AND t.typname = 'PostState';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'PostState' AND e.enumlabel = 'Published') THEN
		--ALTER TYPE "StandardObjects"."PostState" ADD VALUE IF NOT EXISTS 'Published'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Published', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'StandardObjects' AND t.typname = 'PostState';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'PostState' AND e.enumlabel = 'Hidden') THEN
		--ALTER TYPE "StandardObjects"."PostState" ADD VALUE IF NOT EXISTS 'Hidden'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Hidden', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'StandardObjects' AND t.typname = 'PostState';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'URI') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "URI" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."URI" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'ID') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "ID" INT;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."ID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'ID') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "ID" INT;
		COMMENT ON COLUMN "StandardObjects"."Post"."ID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'title') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "title" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."title" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'title') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "title" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."Post"."title" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'text') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "text" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."text" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'text') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "text" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."Post"."text" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'created') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "created" DATE;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."created" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'created') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "created" DATE;
		COMMENT ON COLUMN "StandardObjects"."Post"."created" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'tags') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "tags" VARCHAR[];
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."tags" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'tags') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "tags" VARCHAR[];
		COMMENT ON COLUMN "StandardObjects"."Post"."tags" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'approved') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "approved" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."approved" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'approved') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "approved" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."Post"."approved" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'lastModified') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "lastModified" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."lastModified" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'lastModified') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "lastModified" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."Post"."lastModified" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'commentsURI') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "commentsURI" VARCHAR[];
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."commentsURI" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'votes') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "votes" "StandardObjects"."-ngs_Vote_type-";
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."votes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'votes') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "votes" "StandardObjects"."Vote";
		COMMENT ON COLUMN "StandardObjects"."Post"."votes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'notes') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "notes" VARCHAR[];
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."notes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'notes') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "notes" VARCHAR[];
		COMMENT ON COLUMN "StandardObjects"."Post"."notes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'state') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "state" "StandardObjects"."PostState";
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."state" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Post' AND column_name = 'state') THEN
		ALTER TABLE "StandardObjects"."Post" ADD COLUMN "state" "StandardObjects"."PostState";
		COMMENT ON COLUMN "StandardObjects"."Post"."state" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'CommentState' AND e.enumlabel = 'Pending') THEN
		--ALTER TYPE "StandardObjects"."CommentState" ADD VALUE IF NOT EXISTS 'Pending'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Pending', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'StandardObjects' AND t.typname = 'CommentState';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'CommentState' AND e.enumlabel = 'Approved') THEN
		--ALTER TYPE "StandardObjects"."CommentState" ADD VALUE IF NOT EXISTS 'Approved'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Approved', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'StandardObjects' AND t.typname = 'CommentState';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_enum e JOIN pg_type t ON e.enumtypid = t.oid JOIN pg_namespace n ON n.oid = t.typnamespace WHERE n.nspname = 'StandardObjects' AND t.typname = 'CommentState' AND e.enumlabel = 'Removed') THEN
		--ALTER TYPE "StandardObjects"."CommentState" ADD VALUE IF NOT EXISTS 'Removed'; -- this doesn't work inside a transaction ;( use a hack to add new values...
		--TODO: detect OID wraparounds and throw an exception in that case
		INSERT INTO pg_enum(enumtypid, enumlabel, enumsortorder)
		SELECT t.oid, 'Removed', (SELECT MAX(enumsortorder) + 1 FROM pg_enum e WHERE e.enumtypid = t.oid)
		FROM pg_type t 
		INNER JOIN pg_namespace n ON n.oid = t.typnamespace 
		WHERE n.nspname = 'StandardObjects' AND t.typname = 'CommentState';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'URI') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "URI" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."URI" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'created') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "created" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."created" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Comment' AND column_name = 'created') THEN
		ALTER TABLE "StandardObjects"."Comment" ADD COLUMN "created" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."Comment"."created" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'approved') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "approved" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."approved" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Comment' AND column_name = 'approved') THEN
		ALTER TABLE "StandardObjects"."Comment" ADD COLUMN "approved" TIMESTAMPTZ;
		COMMENT ON COLUMN "StandardObjects"."Comment"."approved" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'user') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "user" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."user" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Comment' AND column_name = 'user') THEN
		ALTER TABLE "StandardObjects"."Comment" ADD COLUMN "user" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."Comment"."user" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'message') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "message" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."message" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Comment' AND column_name = 'message') THEN
		ALTER TABLE "StandardObjects"."Comment" ADD COLUMN "message" VARCHAR;
		COMMENT ON COLUMN "StandardObjects"."Comment"."message" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'votes') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "votes" "StandardObjects"."-ngs_Vote_type-";
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."votes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Comment' AND column_name = 'votes') THEN
		ALTER TABLE "StandardObjects"."Comment" ADD COLUMN "votes" "StandardObjects"."Vote";
		COMMENT ON COLUMN "StandardObjects"."Comment"."votes" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'state') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "state" "StandardObjects"."CommentState";
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."state" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Comment' AND column_name = 'state') THEN
		ALTER TABLE "StandardObjects"."Comment" ADD COLUMN "state" "StandardObjects"."CommentState";
		COMMENT ON COLUMN "StandardObjects"."Comment"."state" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "StandardObjects"."cast_Vote_to_type"("StandardObjects"."Vote") RETURNS "StandardObjects"."-ngs_Vote_type-" AS $$ SELECT $1::text::"StandardObjects"."-ngs_Vote_type-" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION "StandardObjects"."cast_Vote_to_type"("StandardObjects"."-ngs_Vote_type-") RETURNS "StandardObjects"."Vote" AS $$ SELECT $1::text::"StandardObjects"."Vote" $$ IMMUTABLE LANGUAGE sql COST 1;
CREATE OR REPLACE FUNCTION cast_to_text("StandardObjects"."Vote") RETURNS text AS $$ SELECT $1::VARCHAR $$ IMMUTABLE LANGUAGE sql COST 1;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'StandardObjects' AND s.typname = 'Vote' AND t.typname = '-ngs_Vote_type-') THEN
		CREATE CAST ("StandardObjects"."-ngs_Vote_type-" AS "StandardObjects"."Vote") WITH FUNCTION "StandardObjects"."cast_Vote_to_type"("StandardObjects"."-ngs_Vote_type-") AS IMPLICIT;
		CREATE CAST ("StandardObjects"."Vote" AS "StandardObjects"."-ngs_Vote_type-") WITH FUNCTION "StandardObjects"."cast_Vote_to_type"("StandardObjects"."Vote") AS IMPLICIT;
		CREATE CAST ("StandardObjects"."Vote" AS text) WITH FUNCTION cast_to_text("StandardObjects"."Vote") AS ASSIGNMENT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Vote_type-' AND column_name = 'upvote') THEN
		ALTER TYPE "StandardObjects"."-ngs_Vote_type-" ADD ATTRIBUTE "upvote" INT;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Vote_type-"."upvote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Vote' AND column_name = 'upvote') THEN
		ALTER TYPE "StandardObjects"."Vote" ADD ATTRIBUTE "upvote" INT;
		COMMENT ON COLUMN "StandardObjects"."Vote"."upvote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Vote_type-' AND column_name = 'downvote') THEN
		ALTER TYPE "StandardObjects"."-ngs_Vote_type-" ADD ATTRIBUTE "downvote" INT;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Vote_type-"."downvote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Vote' AND column_name = 'downvote') THEN
		ALTER TYPE "StandardObjects"."Vote" ADD ATTRIBUTE "downvote" INT;
		COMMENT ON COLUMN "StandardObjects"."Vote"."downvote" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Page_type-' AND column_name = 'BookID') THEN
		ALTER TYPE "LargeObjects"."-ngs_Page_type-" ADD ATTRIBUTE "BookID" INT;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Page_type-"."BookID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Page' AND column_name = 'BookID') THEN
		ALTER TABLE "LargeObjects"."Page" ADD COLUMN "BookID" INT;
		COMMENT ON COLUMN "LargeObjects"."Page"."BookID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Page_type-' AND column_name = 'Index') THEN
		ALTER TYPE "LargeObjects"."-ngs_Page_type-" ADD ATTRIBUTE "Index" INT;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Page_type-"."Index" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Page' AND column_name = 'Index') THEN
		ALTER TABLE "LargeObjects"."Page" ADD COLUMN "Index" INT;
		COMMENT ON COLUMN "LargeObjects"."Page"."Index" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'PostID') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "PostID" INT;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."PostID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Comment' AND column_name = 'PostID') THEN
		ALTER TABLE "StandardObjects"."Comment" ADD COLUMN "PostID" INT;
		COMMENT ON COLUMN "StandardObjects"."Comment"."PostID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Comment_type-' AND column_name = 'Index') THEN
		ALTER TYPE "StandardObjects"."-ngs_Comment_type-" ADD ATTRIBUTE "Index" INT;
		COMMENT ON COLUMN "StandardObjects"."-ngs_Comment_type-"."Index" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'Comment' AND column_name = 'Index') THEN
		ALTER TABLE "StandardObjects"."Comment" ADD COLUMN "Index" INT;
		COMMENT ON COLUMN "StandardObjects"."Comment"."Index" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Footnote_type-' AND column_name = 'note') THEN
		ALTER TYPE "LargeObjects"."-ngs_Footnote_type-" ADD ATTRIBUTE "note" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Footnote_type-"."note" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Footnote' AND column_name = 'note') THEN
		ALTER TYPE "LargeObjects"."Footnote" ADD ATTRIBUTE "note" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."Footnote"."note" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Headnote_type-' AND column_name = 'note') THEN
		ALTER TYPE "LargeObjects"."-ngs_Headnote_type-" ADD ATTRIBUTE "note" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."-ngs_Headnote_type-"."note" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = 'Headnote' AND column_name = 'note') THEN
		ALTER TYPE "LargeObjects"."Headnote" ADD ATTRIBUTE "note" VARCHAR;
		COMMENT ON COLUMN "LargeObjects"."Headnote"."note" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'LargeObjects' AND type_name = '-ngs_Book_type-' AND column_name = 'pages') THEN
		ALTER TYPE "LargeObjects"."-ngs_Book_type-" ADD ATTRIBUTE "pages" "LargeObjects"."-ngs_Page_type-"[];
		COMMENT ON COLUMN "LargeObjects"."-ngs_Book_type-"."pages" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_Post_type-' AND column_name = 'comments') THEN
		ALTER TYPE "StandardObjects"."-ngs_Post_type-" ADD ATTRIBUTE "comments" "StandardObjects"."-ngs_Comment_type-"[];
		COMMENT ON COLUMN "StandardObjects"."-ngs_Post_type-"."comments" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW "LargeObjects"."Page_entity" AS
SELECT "-NGS-".Generate_Uri2(CAST(_entity."BookID" as TEXT), CAST(_entity."Index" as TEXT)) AS "URI" , _entity."text", _entity."notes", _entity."illustrations", _entity."identity", _entity."BookID", _entity."Index"
FROM
	"LargeObjects"."Page" _entity
	;
COMMENT ON VIEW "LargeObjects"."Page_entity" IS 'NGS volatile';

CREATE OR REPLACE VIEW "SmallObjects"."Message_event" AS
SELECT _event.event_id::text AS "URI", _event.event_id, _event.queued_at AS "QueuedAt", _event.processed_at AS "ProcessedAt" , _event."message"
FROM
	"SmallObjects"."Message" _event
;

CREATE OR REPLACE VIEW "SmallObjects"."Post_entity" AS
SELECT CAST(_entity."ID" as TEXT) AS "URI" , _entity."ID", _entity."title", _entity."text", _entity."created"
FROM
	"SmallObjects"."Post" _entity
	;
COMMENT ON VIEW "SmallObjects"."Post_entity" IS 'NGS volatile';

CREATE OR REPLACE VIEW "StandardObjects"."DeletePost_event" AS
SELECT _event.event_id::text AS "URI", _event.event_id, _event.queued_at AS "QueuedAt", _event.processed_at AS "ProcessedAt" , _event."post", _event."reason"
FROM
	"StandardObjects"."DeletePost" _event
;

CREATE OR REPLACE VIEW "StandardObjects"."Comment_entity" AS
SELECT "-NGS-".Generate_Uri2(CAST(_entity."PostID" as TEXT), CAST(_entity."Index" as TEXT)) AS "URI" , _entity."created", _entity."approved", _entity."user", _entity."message", _entity."votes", _entity."state", _entity."PostID", _entity."Index"
FROM
	"StandardObjects"."Comment" _entity
	;
COMMENT ON VIEW "StandardObjects"."Comment_entity" IS 'NGS volatile';

CREATE OR REPLACE VIEW "LargeObjects"."Book_entity" AS
SELECT CAST(_entity."ID" as TEXT) AS "URI" , _entity."ID", _entity."title", _entity."authorId", COALESCE((SELECT array_agg(sq ORDER BY sq."Index") FROM "LargeObjects"."Page_entity" sq WHERE sq."BookID" = _entity."ID"), '{}') AS "pages", _entity."published", _entity."frontCover", _entity."backCover", _entity."changes", _entity."metadata"
FROM
	"LargeObjects"."Book" _entity
	;
COMMENT ON VIEW "LargeObjects"."Book_entity" IS 'NGS volatile';

CREATE OR REPLACE VIEW "StandardObjects"."Post_entity" AS
SELECT CAST(_entity."ID" as TEXT) AS "URI" , _entity."ID", _entity."title", _entity."text", _entity."created", _entity."tags", _entity."approved", _entity."lastModified", COALESCE((SELECT array_agg(sq ORDER BY sq."Index") FROM "StandardObjects"."Comment_entity" sq WHERE sq."PostID" = _entity."ID"), '{}') AS "comments", _entity."votes", _entity."notes", _entity."state"
FROM
	"StandardObjects"."Post" _entity
	;
COMMENT ON VIEW "StandardObjects"."Post_entity" IS 'NGS volatile';

CREATE OR REPLACE FUNCTION "SmallObjects"."mark_Message"(_events BIGINT[])
	RETURNS VOID AS
$$
BEGIN
	UPDATE "SmallObjects"."Message" SET processed_at = now() WHERE event_id = ANY(_events) AND processed_at IS NULL;
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION "StandardObjects"."mark_DeletePost"(_events BIGINT[])
	RETURNS VOID AS
$$
BEGIN
	UPDATE "StandardObjects"."DeletePost" SET processed_at = now() WHERE event_id = ANY(_events) AND processed_at IS NULL;
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."-ngs_Page_type-") RETURNS "LargeObjects"."Page_entity" AS $$ SELECT $1::text::"LargeObjects"."Page_entity" $$ IMMUTABLE LANGUAGE sql;
CREATE OR REPLACE FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."Page_entity") RETURNS "LargeObjects"."-ngs_Page_type-" AS $$ SELECT $1::text::"LargeObjects"."-ngs_Page_type-" $$ IMMUTABLE LANGUAGE sql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'LargeObjects' AND s.typname = 'Page_entity' AND t.typname = '-ngs_Page_type-') THEN
		CREATE CAST ("LargeObjects"."-ngs_Page_type-" AS "LargeObjects"."Page_entity") WITH FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."-ngs_Page_type-") AS IMPLICIT;
		CREATE CAST ("LargeObjects"."Page_entity" AS "LargeObjects"."-ngs_Page_type-") WITH FUNCTION "LargeObjects"."cast_Page_to_type"("LargeObjects"."Page_entity") AS IMPLICIT;
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "SmallObjects"."submit_Message"(IN events "SmallObjects"."Message_event"[], OUT "URI" VARCHAR) 
	RETURNS SETOF VARCHAR AS
$$
DECLARE cnt int;
DECLARE uri VARCHAR;
DECLARE tmp record;
DECLARE newUris VARCHAR[];
BEGIN

	

	FOR uri IN 
		INSERT INTO "SmallObjects"."Message" (queued_at, processed_at, "message")
		SELECT i."QueuedAt", i."ProcessedAt" , i."message"
		FROM unnest(events) i
		RETURNING event_id::text
	LOOP
		"URI" = uri;
		newUris = array_append(newUris, uri);
		RETURN NEXT;
	END LOOP;

	PERFORM "-NGS-".Safe_Notify('events', 'SmallObjects.Message', 'Insert', newUris);
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION "SmallObjects"."cast_Post_to_type"("SmallObjects"."-ngs_Post_type-") RETURNS "SmallObjects"."Post_entity" AS $$ SELECT $1::text::"SmallObjects"."Post_entity" $$ IMMUTABLE LANGUAGE sql;
CREATE OR REPLACE FUNCTION "SmallObjects"."cast_Post_to_type"("SmallObjects"."Post_entity") RETURNS "SmallObjects"."-ngs_Post_type-" AS $$ SELECT $1::text::"SmallObjects"."-ngs_Post_type-" $$ IMMUTABLE LANGUAGE sql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'SmallObjects' AND s.typname = 'Post_entity' AND t.typname = '-ngs_Post_type-') THEN
		CREATE CAST ("SmallObjects"."-ngs_Post_type-" AS "SmallObjects"."Post_entity") WITH FUNCTION "SmallObjects"."cast_Post_to_type"("SmallObjects"."-ngs_Post_type-") AS IMPLICIT;
		CREATE CAST ("SmallObjects"."Post_entity" AS "SmallObjects"."-ngs_Post_type-") WITH FUNCTION "SmallObjects"."cast_Post_to_type"("SmallObjects"."Post_entity") AS IMPLICIT;
	END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "SmallObjects"."persist_Post"(
IN _inserted "SmallObjects"."Post_entity"[], IN _updated_original "SmallObjects"."Post_entity"[], IN _updated_new "SmallObjects"."Post_entity"[], IN _deleted "SmallObjects"."Post_entity"[]) 
	RETURNS VARCHAR AS
$$
DECLARE cnt int;
DECLARE uri VARCHAR;
DECLARE tmp record;
DECLARE _update_count int = array_upper(_updated_new, 1);
DECLARE _delete_count int = array_upper(_deleted, 1);

BEGIN

	SET CONSTRAINTS ALL DEFERRED;

	

	INSERT INTO "SmallObjects"."Post" ("ID", "title", "text", "created")
	SELECT _i."ID", _i."title", _i."text", _i."created" 
	FROM unnest(_inserted) _i;

	

		
	UPDATE "SmallObjects"."Post" as tbl SET 
		"ID" = _updated_new[_i]."ID", "title" = _updated_new[_i]."title", "text" = _updated_new[_i]."text", "created" = _updated_new[_i]."created"
	FROM generate_series(1, _update_count) _i
	WHERE
		tbl."ID" = _updated_original[_i]."ID";

	GET DIAGNOSTICS cnt = ROW_COUNT;
	IF cnt != _update_count THEN 
		RETURN 'Updated ' || cnt || ' row(s). Expected to update ' || _update_count || ' row(s).';
	END IF;

	

	DELETE FROM "SmallObjects"."Post"
	WHERE ("ID") IN (SELECT _d."ID" FROM unnest(_deleted) _d);

	GET DIAGNOSTICS cnt = ROW_COUNT;
	IF cnt != _delete_count THEN 
		RETURN 'Deleted ' || cnt || ' row(s). Expected to delete ' || _delete_count || ' row(s).';
	END IF;

	
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'SmallObjects.Post', 'Insert', (SELECT array_agg("URI") FROM unnest(_inserted)));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'SmallObjects.Post', 'Update', (SELECT array_agg("URI") FROM unnest(_updated_original)));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'SmallObjects.Post', 'Change', (SELECT array_agg(_updated_new[_i]."URI") FROM generate_series(1, _update_count) _i WHERE _updated_original[_i]."URI" != _updated_new[_i]."URI"));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'SmallObjects.Post', 'Delete', (SELECT array_agg("URI") FROM unnest(_deleted)));

	SET CONSTRAINTS ALL IMMEDIATE;

	RETURN NULL;
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE VIEW "SmallObjects"."Post_unprocessed_events" AS
SELECT _aggregate."ID"
FROM
	"SmallObjects"."Post_entity" _aggregate
;
COMMENT ON VIEW "SmallObjects"."Post_unprocessed_events" IS 'NGS volatile';

CREATE OR REPLACE FUNCTION "StandardObjects"."submit_DeletePost"(IN events "StandardObjects"."DeletePost_event"[], OUT "URI" VARCHAR) 
	RETURNS SETOF VARCHAR AS
$$
DECLARE cnt int;
DECLARE uri VARCHAR;
DECLARE tmp record;
DECLARE newUris VARCHAR[];
BEGIN

	

	FOR uri IN 
		INSERT INTO "StandardObjects"."DeletePost" (queued_at, processed_at, "post", "reason")
		SELECT i."QueuedAt", i."ProcessedAt" , i."post", i."reason"
		FROM unnest(events) i
		RETURNING event_id::text
	LOOP
		"URI" = uri;
		newUris = array_append(newUris, uri);
		RETURN NEXT;
	END LOOP;

	PERFORM "-NGS-".Safe_Notify('events', 'StandardObjects.DeletePost', 'Insert', newUris);
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION "StandardObjects"."cast_Comment_to_type"("StandardObjects"."-ngs_Comment_type-") RETURNS "StandardObjects"."Comment_entity" AS $$ SELECT $1::text::"StandardObjects"."Comment_entity" $$ IMMUTABLE LANGUAGE sql;
CREATE OR REPLACE FUNCTION "StandardObjects"."cast_Comment_to_type"("StandardObjects"."Comment_entity") RETURNS "StandardObjects"."-ngs_Comment_type-" AS $$ SELECT $1::text::"StandardObjects"."-ngs_Comment_type-" $$ IMMUTABLE LANGUAGE sql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'StandardObjects' AND s.typname = 'Comment_entity' AND t.typname = '-ngs_Comment_type-') THEN
		CREATE CAST ("StandardObjects"."-ngs_Comment_type-" AS "StandardObjects"."Comment_entity") WITH FUNCTION "StandardObjects"."cast_Comment_to_type"("StandardObjects"."-ngs_Comment_type-") AS IMPLICIT;
		CREATE CAST ("StandardObjects"."Comment_entity" AS "StandardObjects"."-ngs_Comment_type-") WITH FUNCTION "StandardObjects"."cast_Comment_to_type"("StandardObjects"."Comment_entity") AS IMPLICIT;
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

	

	INSERT INTO "LargeObjects"."Book" ("ID", "title", "authorId", "published", "frontCover", "backCover", "changes", "metadata")
	SELECT (tuple)."ID", (tuple)."title", (tuple)."authorId", (tuple)."published", (tuple)."frontCover", (tuple)."backCover", (tuple)."changes", (tuple)."metadata" 
	FROM "LargeObjects".">tmp-Book-insert<" i;

	
	INSERT INTO "LargeObjects"."Page" ("text", "notes", "illustrations", "identity", "BookID", "Index")
	SELECT (tuple)."text", (tuple)."notes", (tuple)."illustrations", (tuple)."identity", (tuple)."BookID", (tuple)."Index" 
	FROM "LargeObjects".">tmp-Book-insert764896781<" t;

		
	UPDATE "LargeObjects"."Book" as tbl SET 
		"ID" = (new)."ID", "title" = (new)."title", "authorId" = (new)."authorId", "published" = (new)."published", "frontCover" = (new)."frontCover", "backCover" = (new)."backCover", "changes" = (new)."changes", "metadata" = (new)."metadata"
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
		"text" = (u.changed)."text", "notes" = (u.changed)."notes", "illustrations" = (u.changed)."illustrations", "identity" = (u.changed)."identity", "BookID" = (u.changed)."BookID", "Index" = (u.changed)."Index"
	FROM "LargeObjects".">tmp-Book-update764896781<" u
	WHERE
		NOT u.changed IS NULL
		AND NOT u.old IS NULL
		AND u.old != u.changed
		AND tbl."BookID" = (u.old)."BookID" AND tbl."Index" = (u.old)."Index" ;

	INSERT INTO "LargeObjects"."Page" ("text", "notes", "illustrations", "identity", "BookID", "Index")
	SELECT (new)."text", (new)."notes", (new)."illustrations", (new)."identity", (new)."BookID", (new)."Index"
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

CREATE OR REPLACE FUNCTION "StandardObjects"."cast_Post_to_type"("StandardObjects"."-ngs_Post_type-") RETURNS "StandardObjects"."Post_entity" AS $$ SELECT $1::text::"StandardObjects"."Post_entity" $$ IMMUTABLE LANGUAGE sql;
CREATE OR REPLACE FUNCTION "StandardObjects"."cast_Post_to_type"("StandardObjects"."Post_entity") RETURNS "StandardObjects"."-ngs_Post_type-" AS $$ SELECT $1::text::"StandardObjects"."-ngs_Post_type-" $$ IMMUTABLE LANGUAGE sql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_cast c JOIN pg_type s ON c.castsource = s.oid JOIN pg_type t ON c.casttarget = t.oid JOIN pg_namespace n ON n.oid = s.typnamespace AND n.oid = t.typnamespace
					WHERE n.nspname = 'StandardObjects' AND s.typname = 'Post_entity' AND t.typname = '-ngs_Post_type-') THEN
		CREATE CAST ("StandardObjects"."-ngs_Post_type-" AS "StandardObjects"."Post_entity") WITH FUNCTION "StandardObjects"."cast_Post_to_type"("StandardObjects"."-ngs_Post_type-") AS IMPLICIT;
		CREATE CAST ("StandardObjects"."Post_entity" AS "StandardObjects"."-ngs_Post_type-") WITH FUNCTION "StandardObjects"."cast_Post_to_type"("StandardObjects"."Post_entity") AS IMPLICIT;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '>tmp-Post-insert<' AND column_name = 'tuple') THEN
		DROP TABLE IF EXISTS "StandardObjects".">tmp-Post-insert<";
	END IF;
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '>tmp-Post-update<' AND column_name = 'old') THEN
		DROP TABLE IF EXISTS "StandardObjects".">tmp-Post-update<";
	END IF;
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '>tmp-Post-delete<' AND column_name = 'tuple') THEN
		DROP TABLE IF EXISTS "StandardObjects".">tmp-Post-delete<";
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = '>tmp-Post-insert<') THEN
		CREATE UNLOGGED TABLE "StandardObjects".">tmp-Post-insert<" AS SELECT 0::int as i, t as tuple FROM "StandardObjects"."Post_entity" t LIMIT 0;
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = '>tmp-Post-update<') THEN
		CREATE UNLOGGED TABLE "StandardObjects".">tmp-Post-update<" AS SELECT 0::int as i, t as old, t as new FROM "StandardObjects"."Post_entity" t LIMIT 0;
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = '>tmp-Post-delete<') THEN
		CREATE UNLOGGED TABLE "StandardObjects".">tmp-Post-delete<" AS SELECT 0::int as i, t as tuple FROM "StandardObjects"."Post_entity" t LIMIT 0;
	END IF;

	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '>tmp-Post-insert775804683<' AND column_name = 'tuple') THEN
		DROP TABLE IF EXISTS "StandardObjects".">tmp-Post-insert775804683<";
	END IF;
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '>tmp-Post-update775804683<' AND column_name = 'old') THEN
		DROP TABLE IF EXISTS "StandardObjects".">tmp-Post-update775804683<";
	END IF;
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '>tmp-Post-delete775804683<' AND column_name = 'tuple') THEN
		DROP TABLE IF EXISTS "StandardObjects".">tmp-Post-delete775804683<";
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = '>tmp-Post-insert775804683<') THEN
		CREATE UNLOGGED TABLE "StandardObjects".">tmp-Post-insert775804683<" AS SELECT 0::int as i, 0::int as index, t as tuple FROM "StandardObjects"."Comment_entity" t LIMIT 0;
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = '>tmp-Post-update775804683<') THEN
		CREATE UNLOGGED TABLE "StandardObjects".">tmp-Post-update775804683<" AS SELECT 0::int as i, 0::int as index, t as old, t as changed, t as new, true as is_new FROM "StandardObjects"."Comment_entity" t LIMIT 0;
	END IF;
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'StandardObjects' AND c.relname = '>tmp-Post-delete775804683<') THEN
		CREATE UNLOGGED TABLE "StandardObjects".">tmp-Post-delete775804683<" AS SELECT 0::int as i, 0::int as index, t as tuple FROM "StandardObjects"."Comment_entity" t LIMIT 0;
	END IF;
END $$ LANGUAGE plpgsql;

--TODO: temp fix for rename
DROP FUNCTION IF EXISTS "StandardObjects"."persist_Post_internal"(int, int);

CREATE OR REPLACE FUNCTION "StandardObjects"."persist_Post_internal"(_update_count int, _delete_count int) 
	RETURNS VARCHAR AS
$$
DECLARE cnt int;
DECLARE uri VARCHAR;
DECLARE tmp record;
DECLARE "_var_StandardObjects.Comment" "StandardObjects"."Comment_entity"[];
BEGIN

	SET CONSTRAINTS ALL DEFERRED;

	

	INSERT INTO "StandardObjects"."Post" ("ID", "title", "text", "created", "tags", "approved", "lastModified", "votes", "notes", "state")
	SELECT (tuple)."ID", (tuple)."title", (tuple)."text", (tuple)."created", (tuple)."tags", (tuple)."approved", (tuple)."lastModified", (tuple)."votes", (tuple)."notes", (tuple)."state" 
	FROM "StandardObjects".">tmp-Post-insert<" i;

	
	INSERT INTO "StandardObjects"."Comment" ("created", "approved", "user", "message", "votes", "state", "PostID", "Index")
	SELECT (tuple)."created", (tuple)."approved", (tuple)."user", (tuple)."message", (tuple)."votes", (tuple)."state", (tuple)."PostID", (tuple)."Index" 
	FROM "StandardObjects".">tmp-Post-insert775804683<" t;

		
	UPDATE "StandardObjects"."Post" as tbl SET 
		"ID" = (new)."ID", "title" = (new)."title", "text" = (new)."text", "created" = (new)."created", "tags" = (new)."tags", "approved" = (new)."approved", "lastModified" = (new)."lastModified", "votes" = (new)."votes", "notes" = (new)."notes", "state" = (new)."state"
	FROM "StandardObjects".">tmp-Post-update<" u
	WHERE
		tbl."ID" = (old)."ID";

	GET DIAGNOSTICS cnt = ROW_COUNT;
	IF cnt != _update_count THEN 
		RETURN 'Updated ' || cnt || ' row(s). Expected to update ' || _update_count || ' row(s).';
	END IF;

	
	DELETE FROM "StandardObjects"."Comment" AS tbl
	WHERE 
		("PostID", "Index") IN (SELECT (u.old)."PostID", (u.old)."Index" FROM "StandardObjects".">tmp-Post-update775804683<" u WHERE NOT u.old IS NULL AND u.changed IS NULL);

	UPDATE "StandardObjects"."Comment" AS tbl SET
		"created" = (u.changed)."created", "approved" = (u.changed)."approved", "user" = (u.changed)."user", "message" = (u.changed)."message", "votes" = (u.changed)."votes", "state" = (u.changed)."state", "PostID" = (u.changed)."PostID", "Index" = (u.changed)."Index"
	FROM "StandardObjects".">tmp-Post-update775804683<" u
	WHERE
		NOT u.changed IS NULL
		AND NOT u.old IS NULL
		AND u.old != u.changed
		AND tbl."PostID" = (u.old)."PostID" AND tbl."Index" = (u.old)."Index" ;

	INSERT INTO "StandardObjects"."Comment" ("created", "approved", "user", "message", "votes", "state", "PostID", "Index")
	SELECT (new)."created", (new)."approved", (new)."user", (new)."message", (new)."votes", (new)."state", (new)."PostID", (new)."Index"
	FROM 
		"StandardObjects".">tmp-Post-update775804683<" u
	WHERE u.is_new;
	DELETE FROM "StandardObjects"."Comment"	WHERE ("PostID", "Index") IN (SELECT (tuple)."PostID", (tuple)."Index" FROM "StandardObjects".">tmp-Post-delete775804683<" d);

	DELETE FROM "StandardObjects"."Post"
	WHERE ("ID") IN (SELECT (tuple)."ID" FROM "StandardObjects".">tmp-Post-delete<" d);

	GET DIAGNOSTICS cnt = ROW_COUNT;
	IF cnt != _delete_count THEN 
		RETURN 'Deleted ' || cnt || ' row(s). Expected to delete ' || _delete_count || ' row(s).';
	END IF;

	
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'StandardObjects.Post', 'Insert', (SELECT array_agg((tuple)."URI") FROM "StandardObjects".">tmp-Post-insert<"));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'StandardObjects.Post', 'Update', (SELECT array_agg((old)."URI") FROM "StandardObjects".">tmp-Post-update<"));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'StandardObjects.Post', 'Change', (SELECT array_agg((new)."URI") FROM "StandardObjects".">tmp-Post-update<" WHERE (old)."URI" != (new)."URI"));
	PERFORM "-NGS-".Safe_Notify('aggregate_roots', 'StandardObjects.Post', 'Delete', (SELECT array_agg((tuple)."URI") FROM "StandardObjects".">tmp-Post-delete<"));

	SET CONSTRAINTS ALL IMMEDIATE;

	
	DELETE FROM "StandardObjects".">tmp-Post-insert775804683<";
	DELETE FROM "StandardObjects".">tmp-Post-update775804683<";
	DELETE FROM "StandardObjects".">tmp-Post-delete775804683<";
	DELETE FROM "StandardObjects".">tmp-Post-insert<";
	DELETE FROM "StandardObjects".">tmp-Post-update<";
	DELETE FROM "StandardObjects".">tmp-Post-delete<";

	RETURN NULL;
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION "StandardObjects"."persist_Post"(
IN _inserted "StandardObjects"."Post_entity"[], IN _updated_original "StandardObjects"."Post_entity"[], IN _updated_new "StandardObjects"."Post_entity"[], IN _deleted "StandardObjects"."Post_entity"[]) 
	RETURNS VARCHAR AS
$$
DECLARE cnt int;
DECLARE uri VARCHAR;
DECLARE tmp record;
DECLARE "_var_StandardObjects.Comment" "StandardObjects"."Comment_entity"[];
BEGIN

	INSERT INTO "StandardObjects".">tmp-Post-insert<"
	SELECT i, _inserted[i]
	FROM generate_series(1, array_upper(_inserted, 1)) i;

	INSERT INTO "StandardObjects".">tmp-Post-update<"
	SELECT i, _updated_original[i], _updated_new[i]
	FROM generate_series(1, array_upper(_updated_new, 1)) i;

	INSERT INTO "StandardObjects".">tmp-Post-delete<"
	SELECT i, _deleted[i]
	FROM generate_series(1, array_upper(_deleted, 1)) i;

	
	FOR cnt, "_var_StandardObjects.Comment" IN SELECT t.i, (t.tuple)."comments" AS children FROM "StandardObjects".">tmp-Post-insert<" t LOOP
		INSERT INTO "StandardObjects".">tmp-Post-insert775804683<"
		SELECT cnt, index, "_var_StandardObjects.Comment"[index] from generate_series(1, array_upper("_var_StandardObjects.Comment", 1)) index;
	END LOOP;

	INSERT INTO "StandardObjects".">tmp-Post-update775804683<"
	SELECT i, index, old[index] AS old, (select n from unnest(new) n where n."URI" = old[index]."URI") AS changed, new[index] AS new, not exists(select o from unnest(old) o where o."URI" = new[index]."URI") AND NOT new[index] IS NULL as is_new
	FROM 
		(
			SELECT 
				i, 
				(t.old)."comments" AS old,
				(t.new)."comments" AS new,
				unnest((SELECT array_agg(i) FROM generate_series(1, CASE WHEN coalesce(array_upper((t.old)."comments", 1), 0) > coalesce(array_upper((t.new)."comments", 1),0) THEN array_upper((t.old)."comments", 1) ELSE array_upper((t.new)."comments", 1) END) i)) as index 
			FROM "StandardObjects".">tmp-Post-update<" t
			WHERE 
				NOT (t.old)."comments" IS NULL AND (t.new)."comments" IS NULL
				OR (t.old)."comments" IS NULL AND NOT (t.new)."comments" IS NULL
				OR NOT (t.old)."comments" IS NULL AND NOT (t.new)."comments" IS NULL AND (t.old)."comments" != (t.new)."comments"
		) sq;

	FOR cnt, "_var_StandardObjects.Comment" IN SELECT t.i, (t.tuple)."comments" AS children FROM "StandardObjects".">tmp-Post-delete<" t LOOP
		INSERT INTO "StandardObjects".">tmp-Post-delete775804683<"
		SELECT cnt, index, "_var_StandardObjects.Comment"[index] from generate_series(1, array_upper("_var_StandardObjects.Comment", 1)) index;
	END LOOP;

	RETURN "StandardObjects"."persist_Post_internal"(array_upper(_updated_new, 1), array_upper(_deleted, 1));
END
$$
LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE VIEW "StandardObjects"."Post_unprocessed_events" AS
SELECT _aggregate."ID"
FROM
	"StandardObjects"."Post_entity" _aggregate
;
COMMENT ON VIEW "StandardObjects"."Post_unprocessed_events" IS 'NGS volatile';

SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Footnote_to_type"("LargeObjects"."-ngs_Footnote_type-")', 'LargeObjects', '-ngs_Footnote_type-', 'Footnote');
SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Footnote_to_type"("LargeObjects"."Footnote")', 'LargeObjects', 'Footnote', '-ngs_Footnote_type-');

SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Headnote_to_type"("LargeObjects"."-ngs_Headnote_type-")', 'LargeObjects', '-ngs_Headnote_type-', 'Headnote');
SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Headnote_to_type"("LargeObjects"."Headnote")', 'LargeObjects', 'Headnote', '-ngs_Headnote_type-');

SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Note_to_type"("LargeObjects"."-ngs_Note_type-")', 'LargeObjects', '-ngs_Note_type-', 'Note');
SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Note_to_type"("LargeObjects"."Note")', 'LargeObjects', 'Note', '-ngs_Note_type-');
COMMENT ON VIEW "SmallObjects"."Message_event" IS 'NGS volatile';

SELECT "-NGS-".Create_Type_Cast('"SmallObjects"."cast_Complex_to_type"("SmallObjects"."-ngs_Complex_type-")', 'SmallObjects', '-ngs_Complex_type-', 'Complex');
SELECT "-NGS-".Create_Type_Cast('"SmallObjects"."cast_Complex_to_type"("SmallObjects"."Complex")', 'SmallObjects', 'Complex', '-ngs_Complex_type-');
COMMENT ON VIEW "StandardObjects"."DeletePost_event" IS 'NGS volatile';

SELECT "-NGS-".Create_Type_Cast('"StandardObjects"."cast_Vote_to_type"("StandardObjects"."-ngs_Vote_type-")', 'StandardObjects', '-ngs_Vote_type-', 'Vote');
SELECT "-NGS-".Create_Type_Cast('"StandardObjects"."cast_Vote_to_type"("StandardObjects"."Vote")', 'StandardObjects', 'Vote', '-ngs_Vote_type-');

SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Page_to_type"("LargeObjects"."-ngs_Page_type-")', 'LargeObjects', '-ngs_Page_type-', 'Page_entity');
SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Page_to_type"("LargeObjects"."Page_entity")', 'LargeObjects', 'Page_entity', '-ngs_Page_type-');

SELECT "-NGS-".Create_Type_Cast('"SmallObjects"."cast_Post_to_type"("SmallObjects"."-ngs_Post_type-")', 'SmallObjects', '-ngs_Post_type-', 'Post_entity');
SELECT "-NGS-".Create_Type_Cast('"SmallObjects"."cast_Post_to_type"("SmallObjects"."Post_entity")', 'SmallObjects', 'Post_entity', '-ngs_Post_type-');

SELECT "-NGS-".Create_Type_Cast('"StandardObjects"."cast_Comment_to_type"("StandardObjects"."-ngs_Comment_type-")', 'StandardObjects', '-ngs_Comment_type-', 'Comment_entity');
SELECT "-NGS-".Create_Type_Cast('"StandardObjects"."cast_Comment_to_type"("StandardObjects"."Comment_entity")', 'StandardObjects', 'Comment_entity', '-ngs_Comment_type-');

SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Book_to_type"("LargeObjects"."-ngs_Book_type-")', 'LargeObjects', '-ngs_Book_type-', 'Book_entity');
SELECT "-NGS-".Create_Type_Cast('"LargeObjects"."cast_Book_to_type"("LargeObjects"."Book_entity")', 'LargeObjects', 'Book_entity', '-ngs_Book_type-');

SELECT "-NGS-".Create_Type_Cast('"StandardObjects"."cast_Post_to_type"("StandardObjects"."-ngs_Post_type-")', 'StandardObjects', '-ngs_Post_type-', 'Post_entity');
SELECT "-NGS-".Create_Type_Cast('"StandardObjects"."cast_Post_to_type"("StandardObjects"."Post_entity")', 'StandardObjects', 'Post_entity', '-ngs_Post_type-');
UPDATE "LargeObjects"."Book" SET "ID" = 0 WHERE "ID" IS NULL;
UPDATE "LargeObjects"."Book" SET "title" = '' WHERE "title" IS NULL;
UPDATE "LargeObjects"."Book" SET "authorId" = 0 WHERE "authorId" IS NULL;
UPDATE "LargeObjects"."Book" SET "changes" = '{}' WHERE "changes" IS NULL;
UPDATE "LargeObjects"."Book" SET "metadata" = '' WHERE "metadata" IS NULL;
UPDATE "LargeObjects"."Page" SET "text" = '' WHERE "text" IS NULL;
UPDATE "LargeObjects"."Page" SET "notes" = '{}' WHERE "notes" IS NULL;
UPDATE "LargeObjects"."Page" SET "illustrations" = '{}' WHERE "illustrations" IS NULL;
UPDATE "LargeObjects"."Page" SET "identity" = '00000000-0000-0000-0000-000000000000' WHERE "identity" IS NULL;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_index i JOIN pg_class r ON i.indexrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace WHERE n.nspname = 'SmallObjects' AND r.relname = 'ix_unprocessed_events_SmallObjects_Message') THEN
		CREATE INDEX "ix_unprocessed_events_SmallObjects_Message" ON "SmallObjects"."Message" (event_id) WHERE processed_at IS NULL;
		COMMENT ON INDEX "SmallObjects"."ix_unprocessed_events_SmallObjects_Message" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;
UPDATE "SmallObjects"."Post" SET "ID" = 0 WHERE "ID" IS NULL;
UPDATE "SmallObjects"."Post" SET "title" = '' WHERE "title" IS NULL;
UPDATE "SmallObjects"."Post" SET "text" = '' WHERE "text" IS NULL;
UPDATE "SmallObjects"."Post" SET "created" = CURRENT_DATE WHERE "created" IS NULL;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_index i JOIN pg_class r ON i.indexrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace WHERE n.nspname = 'StandardObjects' AND r.relname = 'ix_unprocessed_events_StandardObjects_DeletePost') THEN
		CREATE INDEX "ix_unprocessed_events_StandardObjects_DeletePost" ON "StandardObjects"."DeletePost" (event_id) WHERE processed_at IS NULL;
		COMMENT ON INDEX "StandardObjects"."ix_unprocessed_events_StandardObjects_DeletePost" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;
UPDATE "StandardObjects"."Post" SET "ID" = 0 WHERE "ID" IS NULL;
UPDATE "StandardObjects"."Post" SET "title" = '' WHERE "title" IS NULL;
UPDATE "StandardObjects"."Post" SET "text" = '' WHERE "text" IS NULL;
UPDATE "StandardObjects"."Post" SET "created" = CURRENT_DATE WHERE "created" IS NULL;
UPDATE "StandardObjects"."Post" SET "tags" = '{}' WHERE "tags" IS NULL;
UPDATE "StandardObjects"."Post" SET "lastModified" = CURRENT_TIMESTAMP WHERE "lastModified" IS NULL;
UPDATE "StandardObjects"."Post" SET "votes" = ROW(NULL,NULL) WHERE "votes"::TEXT IS NULL;
UPDATE "StandardObjects"."Post" SET "state" = 'Draft' WHERE "state" IS NULL;
UPDATE "StandardObjects"."Comment" SET "created" = CURRENT_TIMESTAMP WHERE "created" IS NULL;
UPDATE "StandardObjects"."Comment" SET "message" = '' WHERE "message" IS NULL;
UPDATE "StandardObjects"."Comment" SET "votes" = ROW(NULL,NULL) WHERE "votes"::TEXT IS NULL;
UPDATE "StandardObjects"."Comment" SET "state" = 'Pending' WHERE "state" IS NULL;
UPDATE "LargeObjects"."Page" SET "BookID" = 0 WHERE "BookID" IS NULL;
UPDATE "LargeObjects"."Page" SET "Index" = 0 WHERE "Index" IS NULL;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_index i JOIN pg_class r ON i.indexrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace WHERE n.nspname = 'LargeObjects' AND r.relname = 'ix_Page_BookID') THEN
		CREATE INDEX "ix_Page_BookID" ON "LargeObjects"."Page" ("BookID");
		COMMENT ON INDEX "LargeObjects"."ix_Page_BookID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;
UPDATE "StandardObjects"."Comment" SET "PostID" = 0 WHERE "PostID" IS NULL;
UPDATE "StandardObjects"."Comment" SET "Index" = 0 WHERE "Index" IS NULL;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_index i JOIN pg_class r ON i.indexrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace WHERE n.nspname = 'StandardObjects' AND r.relname = 'ix_Comment_PostID') THEN
		CREATE INDEX "ix_Comment_PostID" ON "StandardObjects"."Comment" ("PostID");
		COMMENT ON INDEX "StandardObjects"."ix_Comment_PostID" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
DECLARE _pk VARCHAR;
BEGIN
	IF EXISTS(SELECT * FROM pg_index i JOIN pg_class c ON i.indrelid = c.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE i.indisprimary AND n.nspname = 'LargeObjects' AND c.relname = 'Book') THEN
		SELECT array_to_string(array_agg(sq.attname), ', ') INTO _pk
		FROM
		(
			SELECT atr.attname
			FROM pg_index i
			JOIN pg_class c ON i.indrelid = c.oid 
			JOIN pg_attribute atr ON atr.attrelid = c.oid 
			WHERE 
				c.oid = '"LargeObjects"."Book"'::regclass
				AND atr.attnum = any(i.indkey)
				AND indisprimary
			ORDER BY (SELECT i FROM generate_subscripts(i.indkey,1) g(i) WHERE i.indkey[i] = atr.attnum LIMIT 1)
		) sq;
		IF ('ID' != _pk) THEN
			RAISE EXCEPTION 'Different primary key defined for table LargeObjects.Book. Expected primary key: ID. Found: %', _pk;
		END IF;
	ELSE
		ALTER TABLE "LargeObjects"."Book" ADD CONSTRAINT "pk_Book" PRIMARY KEY("ID");
		COMMENT ON CONSTRAINT "pk_Book" ON "LargeObjects"."Book" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
DECLARE _pk VARCHAR;
BEGIN
	IF EXISTS(SELECT * FROM pg_index i JOIN pg_class c ON i.indrelid = c.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE i.indisprimary AND n.nspname = 'SmallObjects' AND c.relname = 'Post') THEN
		SELECT array_to_string(array_agg(sq.attname), ', ') INTO _pk
		FROM
		(
			SELECT atr.attname
			FROM pg_index i
			JOIN pg_class c ON i.indrelid = c.oid 
			JOIN pg_attribute atr ON atr.attrelid = c.oid 
			WHERE 
				c.oid = '"SmallObjects"."Post"'::regclass
				AND atr.attnum = any(i.indkey)
				AND indisprimary
			ORDER BY (SELECT i FROM generate_subscripts(i.indkey,1) g(i) WHERE i.indkey[i] = atr.attnum LIMIT 1)
		) sq;
		IF ('ID' != _pk) THEN
			RAISE EXCEPTION 'Different primary key defined for table SmallObjects.Post. Expected primary key: ID. Found: %', _pk;
		END IF;
	ELSE
		ALTER TABLE "SmallObjects"."Post" ADD CONSTRAINT "pk_Post" PRIMARY KEY("ID");
		COMMENT ON CONSTRAINT "pk_Post" ON "SmallObjects"."Post" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
DECLARE _pk VARCHAR;
BEGIN
	IF EXISTS(SELECT * FROM pg_index i JOIN pg_class c ON i.indrelid = c.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE i.indisprimary AND n.nspname = 'StandardObjects' AND c.relname = 'Post') THEN
		SELECT array_to_string(array_agg(sq.attname), ', ') INTO _pk
		FROM
		(
			SELECT atr.attname
			FROM pg_index i
			JOIN pg_class c ON i.indrelid = c.oid 
			JOIN pg_attribute atr ON atr.attrelid = c.oid 
			WHERE 
				c.oid = '"StandardObjects"."Post"'::regclass
				AND atr.attnum = any(i.indkey)
				AND indisprimary
			ORDER BY (SELECT i FROM generate_subscripts(i.indkey,1) g(i) WHERE i.indkey[i] = atr.attnum LIMIT 1)
		) sq;
		IF ('ID' != _pk) THEN
			RAISE EXCEPTION 'Different primary key defined for table StandardObjects.Post. Expected primary key: ID. Found: %', _pk;
		END IF;
	ELSE
		ALTER TABLE "StandardObjects"."Post" ADD CONSTRAINT "pk_Post" PRIMARY KEY("ID");
		COMMENT ON CONSTRAINT "pk_Post" ON "StandardObjects"."Post" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
DECLARE _pk VARCHAR;
BEGIN
	IF EXISTS(SELECT * FROM pg_index i JOIN pg_class c ON i.indrelid = c.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE i.indisprimary AND n.nspname = 'LargeObjects' AND c.relname = 'Page') THEN
		SELECT array_to_string(array_agg(sq.attname), ', ') INTO _pk
		FROM
		(
			SELECT atr.attname
			FROM pg_index i
			JOIN pg_class c ON i.indrelid = c.oid 
			JOIN pg_attribute atr ON atr.attrelid = c.oid 
			WHERE 
				c.oid = '"LargeObjects"."Page"'::regclass
				AND atr.attnum = any(i.indkey)
				AND indisprimary
			ORDER BY (SELECT i FROM generate_subscripts(i.indkey,1) g(i) WHERE i.indkey[i] = atr.attnum LIMIT 1)
		) sq;
		IF ('BookID, Index' != _pk) THEN
			RAISE EXCEPTION 'Different primary key defined for table LargeObjects.Page. Expected primary key: BookID, Index. Found: %', _pk;
		END IF;
	ELSE
		ALTER TABLE "LargeObjects"."Page" ADD CONSTRAINT "pk_Page" PRIMARY KEY("BookID","Index");
		COMMENT ON CONSTRAINT "pk_Page" ON "LargeObjects"."Page" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ 
DECLARE _pk VARCHAR;
BEGIN
	IF EXISTS(SELECT * FROM pg_index i JOIN pg_class c ON i.indrelid = c.oid JOIN pg_namespace n ON c.relnamespace = n.oid WHERE i.indisprimary AND n.nspname = 'StandardObjects' AND c.relname = 'Comment') THEN
		SELECT array_to_string(array_agg(sq.attname), ', ') INTO _pk
		FROM
		(
			SELECT atr.attname
			FROM pg_index i
			JOIN pg_class c ON i.indrelid = c.oid 
			JOIN pg_attribute atr ON atr.attrelid = c.oid 
			WHERE 
				c.oid = '"StandardObjects"."Comment"'::regclass
				AND atr.attnum = any(i.indkey)
				AND indisprimary
			ORDER BY (SELECT i FROM generate_subscripts(i.indkey,1) g(i) WHERE i.indkey[i] = atr.attnum LIMIT 1)
		) sq;
		IF ('PostID, Index' != _pk) THEN
			RAISE EXCEPTION 'Different primary key defined for table StandardObjects.Comment. Expected primary key: PostID, Index. Found: %', _pk;
		END IF;
	ELSE
		ALTER TABLE "StandardObjects"."Comment" ADD CONSTRAINT "pk_Comment" PRIMARY KEY("PostID","Index");
		COMMENT ON CONSTRAINT "pk_Comment" ON "StandardObjects"."Comment" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;
ALTER TABLE "LargeObjects"."Book" ALTER "ID" SET NOT NULL;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid WHERE n.nspname = 'LargeObjects' AND c.relname = 'Book_ID_seq' AND c.relkind = 'S') THEN
		CREATE SEQUENCE "LargeObjects"."Book_ID_seq";
		ALTER TABLE "LargeObjects"."Book"	ALTER COLUMN "ID" SET DEFAULT NEXTVAL('"LargeObjects"."Book_ID_seq"');
		PERFORM SETVAL('"LargeObjects"."Book_ID_seq"', COALESCE(MAX("ID"), 0) + 1000) FROM "LargeObjects"."Book";
	END IF;
END $$ LANGUAGE plpgsql;
ALTER TABLE "LargeObjects"."Book" ALTER "title" SET NOT NULL;
ALTER TABLE "LargeObjects"."Book" ALTER "authorId" SET NOT NULL;
ALTER TABLE "LargeObjects"."Book" ALTER "changes" SET NOT NULL;
ALTER TABLE "LargeObjects"."Book" ALTER "metadata" SET NOT NULL;
ALTER TABLE "LargeObjects"."Page" ALTER "text" SET NOT NULL;
ALTER TABLE "LargeObjects"."Page" ALTER "notes" SET NOT NULL;
ALTER TABLE "LargeObjects"."Page" ALTER "illustrations" SET NOT NULL;
ALTER TABLE "LargeObjects"."Page" ALTER "identity" SET NOT NULL;
ALTER TABLE "SmallObjects"."Post" ALTER "ID" SET NOT NULL;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid WHERE n.nspname = 'SmallObjects' AND c.relname = 'Post_ID_seq' AND c.relkind = 'S') THEN
		CREATE SEQUENCE "SmallObjects"."Post_ID_seq";
		ALTER TABLE "SmallObjects"."Post"	ALTER COLUMN "ID" SET DEFAULT NEXTVAL('"SmallObjects"."Post_ID_seq"');
		PERFORM SETVAL('"SmallObjects"."Post_ID_seq"', COALESCE(MAX("ID"), 0) + 1000) FROM "SmallObjects"."Post";
	END IF;
END $$ LANGUAGE plpgsql;
ALTER TABLE "SmallObjects"."Post" ALTER "title" SET NOT NULL;
ALTER TABLE "SmallObjects"."Post" ALTER "text" SET NOT NULL;
ALTER TABLE "SmallObjects"."Post" ALTER "created" SET NOT NULL;
ALTER TABLE "StandardObjects"."Post" ALTER "ID" SET NOT NULL;

DO $$ 
BEGIN
	IF NOT EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON c.relnamespace = n.oid WHERE n.nspname = 'StandardObjects' AND c.relname = 'Post_ID_seq' AND c.relkind = 'S') THEN
		CREATE SEQUENCE "StandardObjects"."Post_ID_seq";
		ALTER TABLE "StandardObjects"."Post"	ALTER COLUMN "ID" SET DEFAULT NEXTVAL('"StandardObjects"."Post_ID_seq"');
		PERFORM SETVAL('"StandardObjects"."Post_ID_seq"', COALESCE(MAX("ID"), 0) + 1000) FROM "StandardObjects"."Post";
	END IF;
END $$ LANGUAGE plpgsql;
ALTER TABLE "StandardObjects"."Post" ALTER "title" SET NOT NULL;
ALTER TABLE "StandardObjects"."Post" ALTER "text" SET NOT NULL;
ALTER TABLE "StandardObjects"."Post" ALTER "created" SET NOT NULL;
ALTER TABLE "StandardObjects"."Post" ALTER "tags" SET NOT NULL;
ALTER TABLE "StandardObjects"."Post" ALTER "lastModified" SET NOT NULL;
ALTER TABLE "StandardObjects"."Post" ALTER "votes" SET NOT NULL;
ALTER TABLE "StandardObjects"."Post" ALTER "state" SET NOT NULL;
ALTER TABLE "StandardObjects"."Comment" ALTER "created" SET NOT NULL;
ALTER TABLE "StandardObjects"."Comment" ALTER "message" SET NOT NULL;
ALTER TABLE "StandardObjects"."Comment" ALTER "votes" SET NOT NULL;
ALTER TABLE "StandardObjects"."Comment" ALTER "state" SET NOT NULL;
ALTER TABLE "LargeObjects"."Page" ALTER "BookID" SET NOT NULL;
ALTER TABLE "LargeObjects"."Page" ALTER "Index" SET NOT NULL;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_constraint c JOIN pg_class r ON c.conrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace WHERE c.conname = 'fk_pages' AND n.nspname = 'LargeObjects' AND r.relname = 'Page') THEN	
		ALTER TABLE "LargeObjects"."Page" 
			ADD CONSTRAINT "fk_pages"
				FOREIGN KEY ("BookID") REFERENCES "LargeObjects"."Book" ("ID")
				ON UPDATE CASCADE ON DELETE CASCADE;
		COMMENT ON CONSTRAINT "fk_pages" ON "LargeObjects"."Page" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;
ALTER TABLE "StandardObjects"."Comment" ALTER "PostID" SET NOT NULL;
ALTER TABLE "StandardObjects"."Comment" ALTER "Index" SET NOT NULL;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM pg_constraint c JOIN pg_class r ON c.conrelid = r.oid JOIN pg_namespace n ON n.oid = r.relnamespace WHERE c.conname = 'fk_comments' AND n.nspname = 'StandardObjects' AND r.relname = 'Comment') THEN	
		ALTER TABLE "StandardObjects"."Comment" 
			ADD CONSTRAINT "fk_comments"
				FOREIGN KEY ("PostID") REFERENCES "StandardObjects"."Post" ("ID")
				ON UPDATE CASCADE ON DELETE CASCADE;
		COMMENT ON CONSTRAINT "fk_comments" ON "StandardObjects"."Comment" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

SELECT "-NGS-".Persist_Concepts('"LargeObjects.dsl"=>"module LargeObjects {
	root Book {
		string title;
		int authorId;
		List<Page> pages;
		date? published;
		binary? frontCover;
		binary? backCover;
		Set<Date> changes;
		Map metadata;
	}

	entity Page {
		string text;
		List<Note> notes;
		List<binary> illustrations;
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
	}
}","SmallObjects.dsl"=>"module SmallObjects {
	event Message {
		string message;
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
	event DeletePost {
		Post post;
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
}"', '\x','1.0.3.21525')