module StandardObjects {
	value DeletePost {
		int postID;
		guid? referenceId;
		timestamp lastModified {
			//otherwise we will get current timestamp
			default c# 'System.DateTime.MinValue';
			default Java 'com.dslplatform.client.Utils.MIN_DATE_TIME'; 
		}
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
	value Post {
		int ID;
		string title;
		string text;
		date created {
			//otherwise we will get current date
			default c# 'System.DateTime.MinValue';
			default Java 'com.dslplatform.client.Utils.MIN_LOCAL_DATE'; 
		}
		Set<string> tags;
		timestamp? approved;
		List<Comment> comments;
		Vote votes;
		List<string>? notes;
		PostState state;
	}
	value Comment {
		date created {
			//otherwise we will get current date
			default c# 'System.DateTime.MinValue';
			default Java 'com.dslplatform.client.Utils.MIN_LOCAL_DATE'; 
		}
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