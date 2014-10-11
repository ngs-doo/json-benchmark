module StandardObjects {
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
}