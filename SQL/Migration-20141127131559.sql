/*MIGRATION_DESCRIPTION
--REMOVE: SmallObjects-Complex-y
Property y will be removed from object Complex in schema SmallObjects
--CREATE: SmallObjects-Complex-y
New property y will be created for Complex in SmallObjects
--CREATE: SmallObjects-Complex-z
New property z will be created for Complex in SmallObjects
--CREATE: StandardObjects-DeletePost-referenceId
New property referenceId will be created for DeletePost in StandardObjects
--CREATE: StandardObjects-DeletePost-versions
New property versions will be created for DeletePost in StandardObjects
--CREATE: StandardObjects-DeletePost-state
New property state will be created for DeletePost in StandardObjects
MIGRATION_DESCRIPTION*/

DO $$ BEGIN
	IF EXISTS(SELECT * FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = '-NGS-' AND c.relname = 'database_setting') THEN	
		IF EXISTS(SELECT * FROM "-NGS-".Database_Setting WHERE Key ILIKE 'mode' AND NOT Value ILIKE 'unsafe') THEN
			RAISE EXCEPTION 'Database upgrade is forbidden. Change database mode to allow upgrade';
		END IF;
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Complex' AND column_name = 'y' AND is_ngs_generated) THEN
		ALTER TYPE "SmallObjects"."Complex" DROP ATTRIBUTE "y";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Complex_type-' AND column_name = 'y' AND is_ngs_generated) THEN
		ALTER TYPE "SmallObjects"."-ngs_Complex_type-" DROP ATTRIBUTE "y";
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Complex_type-' AND column_name = 'y') THEN
		ALTER TYPE "SmallObjects"."-ngs_Complex_type-" ADD ATTRIBUTE "y" REAL;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Complex_type-"."y" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Complex' AND column_name = 'y') THEN
		ALTER TYPE "SmallObjects"."Complex" ADD ATTRIBUTE "y" REAL;
		COMMENT ON COLUMN "SmallObjects"."Complex"."y" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = '-ngs_Complex_type-' AND column_name = 'z') THEN
		ALTER TYPE "SmallObjects"."-ngs_Complex_type-" ADD ATTRIBUTE "z" BIGINT;
		COMMENT ON COLUMN "SmallObjects"."-ngs_Complex_type-"."z" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'SmallObjects' AND type_name = 'Complex' AND column_name = 'z') THEN
		ALTER TYPE "SmallObjects"."Complex" ADD ATTRIBUTE "z" BIGINT;
		COMMENT ON COLUMN "SmallObjects"."Complex"."z" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_DeletePost_type-' AND column_name = 'referenceId') THEN
		ALTER TYPE "StandardObjects"."-ngs_DeletePost_type-" ADD ATTRIBUTE "referenceId" UUID;
		COMMENT ON COLUMN "StandardObjects"."-ngs_DeletePost_type-"."referenceId" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'referenceId') THEN
		ALTER TYPE "StandardObjects"."DeletePost" ADD ATTRIBUTE "referenceId" UUID;
		COMMENT ON COLUMN "StandardObjects"."DeletePost"."referenceId" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_DeletePost_type-' AND column_name = 'versions') THEN
		ALTER TYPE "StandardObjects"."-ngs_DeletePost_type-" ADD ATTRIBUTE "versions" BIGINT[];
		COMMENT ON COLUMN "StandardObjects"."-ngs_DeletePost_type-"."versions" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'versions') THEN
		ALTER TYPE "StandardObjects"."DeletePost" ADD ATTRIBUTE "versions" BIGINT[];
		COMMENT ON COLUMN "StandardObjects"."DeletePost"."versions" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = '-ngs_DeletePost_type-' AND column_name = 'state') THEN
		ALTER TYPE "StandardObjects"."-ngs_DeletePost_type-" ADD ATTRIBUTE "state" "StandardObjects"."PostState";
		COMMENT ON COLUMN "StandardObjects"."-ngs_DeletePost_type-"."state" IS 'NGS generated';
	END IF;
END $$ LANGUAGE plpgsql;

DO $$ BEGIN
	IF NOT EXISTS(SELECT * FROM "-NGS-".Load_Type_Info() WHERE type_schema = 'StandardObjects' AND type_name = 'DeletePost' AND column_name = 'state') THEN
		ALTER TYPE "StandardObjects"."DeletePost" ADD ATTRIBUTE "state" "StandardObjects"."PostState";
		COMMENT ON COLUMN "StandardObjects"."DeletePost"."state" IS 'NGS generated';
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
		float y;
		long z;
	}
}","StandardObjects.dsl"=>"module StandardObjects {
	value DeletePost {
		int postID;
		guid? referenceId;
		timestamp lastModified;
		long deletedBy;
		string? reason;
		long[]? versions;
		PostState? state;
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
}"', '\x','1.0.3.36430')