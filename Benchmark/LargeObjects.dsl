module LargeObjects {
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
}