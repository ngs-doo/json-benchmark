using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;

namespace JsonBenchmark.Models.Standard
{
	[DataContract]
	public enum PostState
	{
		[DataMember]
		Draft,
		[DataMember]
		Published,
		[DataMember]
		Hidden,
	}

	[DataContract]
	public class DeletePost : IEquatable<DeletePost>
	{
		private static DateTime NOW = DateTime.UtcNow;
		private static readonly Guid[] GUIDS = Enumerable.Range(0, 100).Select(it => Guid.NewGuid()).ToArray();

		[DataMember(Order = 1)]
		public int postID { get; set; }
		[DataMember(Order = 2)]
		public Guid? referenceId { get; set; }
		[DataMember(Order = 3)]
		public DateTime lastModified { get; set; }
		[DataMember(Order = 4)]
		public long deletedBy { get; set; }
		[DataMember(Order = 5)]
		public string reason { get; set; }
		[DataMember(Order = 6)]
		public long[] versions { get; set; }
		[DataMember(Order = 7)]
		public PostState? state { get; set; }
		[DataMember(Order = 8)]
		public List<bool?> votes { get; set; }
		public override int GetHashCode() { return postID; }
		public override bool Equals(object obj) { return Equals(obj as DeletePost); }
		public bool Equals(DeletePost other)
		{
			return other != null && other.postID == this.postID && other.referenceId == this.referenceId
				&& other.lastModified == this.lastModified && other.deletedBy == this.deletedBy
				&& other.reason == this.reason
				&& (other.versions == this.versions || other.versions != null && Enumerable.SequenceEqual(other.versions, this.versions))
				&& other.state == this.state
				&& (other.votes == this.votes || other.votes != null && Enumerable.SequenceEqual(other.votes, this.votes));
		}
		public static TD Factory<TD, TS>(int i, Func<int, TS> cast)
			where TD : new()
			where TS : struct
		{
			dynamic delete = new TD();
			delete.postID = i;
			delete.deletedBy = i / 100;
			delete.lastModified = NOW.AddSeconds(i);
			delete.reason = "no reason";
			if (i % 3 == 0) delete.referenceId = GUIDS[i % 100];
			if (i % 5 == 0) delete.state = cast(i % 3);
			if (i % 7 == 0)
			{
				delete.versions = new long[i % 100 + 1];//ProtoBuf hack - always add object since Protobuf can't differentiate
				for (int x = 0; x <= i % 100; x++)
					delete.versions[x] = i * x + x;
			}
			if (i % 2 == 0 && i % 10 != 0)
			{
				delete.votes = new List<bool?>();
				for (int j = 0; j < i % 10; j++)
					delete.votes.Add((i + j) % 3 == 0 ? true : j % 2 == 0 ? (bool?)false : null);
			}
			return delete;
		}
	}
	[DataContract]
	public class Post : IEquatable<Post>
	{
		private static DateTime NOW = DateTime.UtcNow;
		private static DateTime TODAY = DateTime.UtcNow.Date;
		private static string[][] TAGS = new[] { new string[0], new[] { "JSON" }, new[] { ".NET", "Java", "benchmark" } };

		public Post()
		{
			comments = new List<Comment>();
		}

		[DataMember(Order = 2)]
		public int ID { get; set; }
		[DataMember(Order = 3)]
		public string title { get; set; }
		[DataMember(Order = 4)]
		public string text { get; set; }
		[DataMember(Order = 5)]
		public DateTime created { get; set; }
		[DataMember(Order = 6)]
		public HashSet<string> tags { get; set; }
		[DataMember(Order = 7)]
		public DateTime? approved { get; set; }
		[DataMember(Order = 8)]
		public List<Comment> comments { get; set; }
		[DataMember(Order = 9)]
		public Vote votes { get; set; }
		[DataMember(Order = 10)]
		public List<string> notes { get; set; }
		[DataMember(Order = 11)]
		public PostState state { get; set; }
		public override int GetHashCode() { return ID; }
		public override bool Equals(object obj) { return Equals(obj as Post); }
		public bool Equals(Post other)
		{
			var otherTags = other == null || other.tags == null ? null : other.tags.ToList();
			var thisTags = this.tags != null ? this.tags.ToList() : null;
			if (thisTags != null) thisTags.Sort();
			if (otherTags != null) otherTags.Sort();
			return other != null && other.ID == this.ID && other.title == this.title
				&& other.text == this.text && other.created == this.created
				&& (otherTags == thisTags || otherTags != null && thisTags != null && Enumerable.SequenceEqual(otherTags, thisTags))
				&& other.approved == this.approved
				&& Enumerable.SequenceEqual(other.comments, this.comments)
				&& other.votes.Equals(this.votes)
				&& (other.notes == this.notes || other.notes != null && Enumerable.SequenceEqual(other.notes, this.notes))
				&& other.state == this.state;
		}
		public static TP Factory<TP, TV, TS, TC>(int i, Func<int, TS> cast)
			where TP : new()
			where TV : new()
			where TC : new()
			where TS : struct
		{
			dynamic post = new TP();
			post.ID = -i;
			post.approved = i % 2 == 0 ? null : (DateTime?)NOW.AddMilliseconds(i);
			dynamic votes = new TV();
			votes.downvote = i / 3;
			votes.upvote = i / 2;
			post.votes = votes;
			post.text = "some text describing post " + i;
			post.title = "post title " + i;
			post.state = cast(i % 3);
			post.tags = new HashSet<string>(TAGS[i % 3]);
			post.created = TODAY.AddDays(i);
			for (int j = 0; j < i % 100; j++)
			{
				dynamic comment = new TC();
				comment.created = TODAY.AddDays(i + j);
				comment.message = "comment number " + i + " for " + j;
				dynamic v = new TV();
				v.upvote = j;
				v.downvote = j * 2;
				comment.votes = v;
				comment.approved = j % 3 != 0 ? null : (DateTime?)NOW.AddMilliseconds(i);
				comment.user = "some random user " + i;
				post.comments.Add(comment);
			}
			return post;
		}
	}
	[DataContract]
	public class Comment : IEquatable<Comment>
	{
		[DataMember(Order = 4)]
		public DateTime created { get; set; }
		[DataMember(Order = 5)]
		public DateTime? approved { get; set; }
		[DataMember(Order = 6)]
		public string user { get; set; }
		[DataMember(Order = 7)]
		public string message { get; set; }
		[DataMember(Order = 8)]
		public Vote votes { get; set; }
		public override int GetHashCode() { return created.GetHashCode(); }
		public override bool Equals(object obj) { return Equals(obj as Comment); }
		public bool Equals(Comment other)
		{
			return other != null
				&& other.created == this.created && other.approved == this.approved && other.user == this.user
				&& other.message == this.message && other.votes.Equals(this.votes);
		}
	}
	[DataContract]
	public class Vote : IEquatable<Vote>
	{
		[DataMember(Order = 1)]
		public int upvote { get; set; }
		[DataMember(Order = 2)]
		public int downvote { get; set; }
		public override int GetHashCode() { return upvote ^ downvote; }
		public override bool Equals(object obj) { return Equals(obj as Vote); }
		public bool Equals(Vote other)
		{
			return other != null && other.upvote == this.upvote && other.downvote == this.downvote;
		}
	}
}
