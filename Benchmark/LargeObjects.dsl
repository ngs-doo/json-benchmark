module LargeObjects {
	value Book {
		int ID;
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
	value Page {
		string text;
		List<Note> notes;
		guid identity;
	}
	value Footnote {
		has mixin Note;
		timestamp createadAt { 
			//otherwise we will get current date
			default c# 'System.DateTime.MinValue';
			default Java 'com.dslplatform.json.JodaTimeConverter.MIN_DATE_TIME';
		}
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