module StandardObjects {
	value DeletePost {
		int postID;
		guid? referenceId;
		timestamp lastModified;
		long deletedBy;
		string? reason;
		long[]? versions; //Issue: ProtoBuf doesn't differentiate empty array from null
		PostState? state;
		list<bool?>? votes; //Issue: list<bool?> required Protobuf modification
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
		List<Comment> comments;
		Vote votes;
		List<string>? notes;
		PostState state;
	}
	entity Comment {
		date created;
		timestamp? approved;
		string? user;
		string message;
		Vote votes;
	}
	value Vote {
		int upvote;
		int downvote;
	}
}