module LargeObjects {
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
}