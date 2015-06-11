using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;

namespace JsonBenchmark.Models.Small
{
	[DataContract]
	public struct Message
	{
		[DataMember(Order = 1)]
		public string message { get; set; }
		[DataMember(Order = 2)]
		public int version { get; set; }
		public static Message FactoryPoco(int i)
		{
			return new Message { message = "some message " + i, version = i };
		}
		public static SmallObjects.Message FactoryDsl(int i)
		{
			return new SmallObjects.Message { message = "some message " + i, version = i };
		}
		public static SmallObjects.Bond.Message FactoryBond(int i)
		{
			return new SmallObjects.Bond.Message { message = "some message " + i, version = i };
		}
	}
	[DataContract]
	public struct Complex
	{
		[DataMember(Order = 1)]
		public decimal x { get; set; }
		[DataMember(Order = 2)]
		public float y { get; set; }
		[DataMember(Order = 3)]
		public long z { get; set; }
		public static Complex FactoryPoco(int i)
		{
			return new Complex { x = i / 1000m, y = -i / 1000f, z = i };
		}
		public static SmallObjects.Complex FactoryDsl(int i)
		{
			return new SmallObjects.Complex { x = i / 1000m, y = -i / 1000f, z = i };
		}
		public static SmallObjects.Bond.Complex FactoryBond(int i)
		{
			return new SmallObjects.Bond.Complex { x = i / 1000m, y = -i / 1000f, z = i };
		}
	}
	[DataContract]
	public class Post : IEquatable<Post>
	{
		private static DateTime NOW = DateTime.UtcNow;

		[DataMember(Order = 1)]
		public string URI { get; set; }
		[DataMember(Order = 2)]
		public Guid ID { get; set; }
		[DataMember(Order = 3)]
		public string title { get; set; }
		[DataMember(Order = 4)]
		public bool active { get; set; }
		[DataMember(Order = 5)]
		public DateTime created { get; set; }
		public override int GetHashCode() { return URI.GetHashCode(); }
		public override bool Equals(object obj) { return Equals(obj as Post); }
		public bool Equals(Post other)
		{
			return other != null && other.URI == this.URI && other.ID == this.ID && other.title == this.title
				&& other.active == this.active && other.created == this.created;
		}
		public static Post FactoryPoco(int i)
		{
			return new Post
			{
				URI = new object().GetHashCode().ToString(),
				ID = Guid.NewGuid(),
				title = "some title " + i,
				active = i % 2 == 0,
				created = NOW.AddMinutes(i).Date
			};
		}
		public static SmallObjects.Post FactoryDsl(int i)
		{
			return new SmallObjects.Post { title = "some title " + i, active = i % 2 == 0, created = NOW.AddMinutes(i).Date };
		}
		public static SmallObjects.Bond.Post FactoryBond(int i)
		{
			return new SmallObjects.Bond.Post
			{
				URI = new object().GetHashCode().ToString(),
				ID = SmallObjects.Bond.BondTypeAliasConverter.Convert(Guid.NewGuid(), new SmallObjects.Bond.GUID()),
				title = "some title " + i,
				active = i % 2 == 0,
				created = NOW.AddMinutes(i).Date
			};
		}
	}
}
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
		public static DeletePost FactoryPoco(int i)
		{
			var delete = new DeletePost { postID = i, deletedBy = i / 100, lastModified = NOW.AddSeconds(i), reason = "no reason" };
			if (i % 3 == 0) delete.referenceId = GUIDS[i % 100];
			if (i % 5 == 0) delete.state = (PostState)(i % 3);
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
		public static StandardObjects.DeletePost FactoryDsl(int i)
		{
			var delete = new StandardObjects.DeletePost { postID = i, deletedBy = i / 100, lastModified = NOW.AddSeconds(i), reason = "no reason" };
			if (i % 3 == 0) delete.referenceId = GUIDS[i % 100];
			if (i % 5 == 0) delete.state = (StandardObjects.PostState)(i % 3);
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
		private static string[][] TAGS = new[] { new string[0], new[] { "JSON" }, new[] { ".NET", "libraries", "benchmark" } };

		public Post()
		{
			comments = new List<Comment>();
		}

		[DataMember(Order = 1)]
		public string URI { get; set; }
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
			var otherTags = other == null ? null : other.tags.ToList();
			var thisTags = this.tags != null ? this.tags.ToList() : null;
			if (thisTags != null) thisTags.Sort();
			if (otherTags != null) otherTags.Sort();
			return other != null && other.URI == this.URI && other.ID == this.ID && other.title == this.title
				&& other.text == this.text && other.created == this.created
				&& (otherTags == thisTags || otherTags != null && Enumerable.SequenceEqual(otherTags, thisTags))
				&& other.approved == this.approved
				&& Enumerable.SequenceEqual(other.comments, this.comments)
				&& other.votes.Equals(this.votes)
				&& (other.notes == this.notes || other.notes != null && Enumerable.SequenceEqual(other.notes, this.notes))
				&& other.state == this.state;
		}
		public static Post FactoryPoco(int i)
		{
			var post = new Post
			{
				URI = new object().GetHashCode().ToString(),
				ID = -i,
				approved = i % 2 == 0 ? null : (DateTime?)NOW.AddMilliseconds(i),
				votes = new Vote { downvote = i / 3, upvote = i / 2 },
				text = "some text describing post " + i,
				title = "post title " + i,
				state = (PostState)(i % 3),
				tags = new HashSet<string>(TAGS[i % 3]),
				created = DateTime.UtcNow
			};
			for (int j = 0; j < i % 100; j++)
			{
				post.comments.Add(
					new Comment
					{
						created = DateTime.UtcNow,
						message = "comment number " + i + " for " + j,
						votes = new Vote { upvote = j, downvote = j * 2 },
						approved = j % 3 != 0 ? null : (DateTime?)NOW.AddMilliseconds(i),
						user = "some random user " + i,
						PostID = post.ID, //TODO: we should not be updating this, but since it's never persisted, it never gets updated
						Index = j
					});
			}
			return post;
		}
		public static StandardObjects.Post FactoryDsl(int i)
		{
			var post = new StandardObjects.Post
			{
				approved = i % 2 == 0 ? null : (DateTime?)NOW.AddMilliseconds(i),
				votes = new StandardObjects.Vote { downvote = i / 3, upvote = i / 2 },
				text = "some text describing post " + i,
				title = "post title " + i,
				state = (StandardObjects.PostState)(i % 3)
			};
			for (int j = 0; j < i % 100; j++)
			{
				post.comments.Add(
					new StandardObjects.Comment
					{
						message = "comment number " + i + " for " + j,
						votes = new StandardObjects.Vote { upvote = j, downvote = j * 2 },
						approved = j % 3 != 0 ? null : (DateTime?)NOW.AddMilliseconds(i),
						user = "some random user " + i,
						PostID = post.ID, //TODO: we should not be updating this, but since it's never persisted, it never gets updated
						Index = j
					});
			}
			return post;
		}
	}
	[DataContract]
	public class Comment : IEquatable<Comment>
	{
		[DataMember(Order = 1)]
		public string URI { get; set; }
		[DataMember(Order = 2)]
		public int PostID { get; set; }
		[DataMember(Order = 3)]
		public int Index { get; set; }
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
		public override int GetHashCode() { return URI.GetHashCode(); }
		public override bool Equals(object obj) { return Equals(obj as Comment); }
		public bool Equals(Comment other)
		{
			return other != null && other.URI == this.URI && other.PostID == this.PostID && other.Index == this.Index
				&& other.created == this.created && other.approved == this.approved && other.user == this.user
				&& other.message == this.message && other.votes.Equals(this.votes);
		}
	}
	[DataContract]
	public struct Vote
	{
		[DataMember(Order = 1)]
		public int upvote { get; set; }
		[DataMember(Order = 2)]
		public int downvote { get; set; }
	}
}
namespace JsonBenchmark.Models.Large
{
	[DataContract]
	public class Book
	{
		private static DateTime NOW = DateTime.UtcNow;
		private static List<byte[]> ILLUSTRATIONS = new List<byte[]>();
		static Book()
		{
			var rnd = new Random(1);
			for (int i = 0; i < 10; i++)
			{
				var buf = new byte[256 * i * i * i];
				rnd.NextBytes(buf);
				ILLUSTRATIONS.Add(buf);
			}
		}

		public Book()
		{
			pages = new LinkedList<Page>();
			changes = new HashSet<DateTime>();
			metadata = new Dictionary<string, string>();
			genres = new Genre[0];
		}
		[DataMember(Order = 1)]
		public string URI { get; set; }
		[DataMember(Order = 2)]
		public int ID { get; set; }
		[DataMember(Order = 3)]
		public string title { get; set; }
		[DataMember(Order = 4)]
		public int authorId { get; set; }
		[DataMember(Order = 5)]
		LinkedList<Page> pages { get; set; }
		[DataMember(Order = 6)]
		public DateTime? published { get; set; }
		[DataMember(Order = 7)]
		public byte[] cover { get; set; }
		[DataMember(Order = 8)]
		public HashSet<DateTime> changes { get; set; }
		[DataMember(Order = 9)]
		public Dictionary<string, string> metadata { get; set; }
		[DataMember(Order = 10)]
		public Genre[] genres { get; set; }
		public static Book FactoryPoco(int i)
		{
			var book = new Book
			{
				URI = new object().GetHashCode().ToString(),
				ID = -i,
				authorId = i / 100,
				published = i % 3 == 0 ? null : (DateTime?)NOW.AddMinutes(i).Date,
				title = "book title " + i
			};
			var genres = new List<Genre>();
			for (int j = 0; j < i % 2; j++)
				genres.Add((Genre)((i + j) % 4));
			book.genres = genres.ToArray();
			for (int j = 0; j < i % 20; j++)
				book.changes.Add(NOW.AddMinutes(i).Date);
			for (int j = 0; j < i % 50; j++)
				book.metadata["key " + i + j] = "value " + i + j;
			if (i % 3 == 0 || i % 7 == 0) book.cover = ILLUSTRATIONS[i % ILLUSTRATIONS.Count];
			var sb = new StringBuilder();
			for (int j = 0; j < i % 1000; j++)
			{
				sb.Append("some text on page " + j);
				sb.Append("more text for " + i);
				var page = new Page
				{
					URI = new object().GetHashCode().ToString(),
					text = sb.ToString(),
					BookID = book.ID, //TODO: we should not be updating this, but since it's never persisted, it never gets updated
					Index = j
				};
				for (int z = 0; z < i % 100; z++)
				{
					Note note;
					if (z % 3 == 0)
						note = new Headnote { modifiedAt = NOW.AddSeconds(i), note = "headnote " + j + " at " + z };
					else
						note = new Footnote { createadAt = NOW.AddSeconds(i), note = "footnote " + j + " at " + z, index = i };
					if (z % 3 == 0)
						note.writtenBy = "author " + j + " " + z;
					page.notes.Add(note);
				}
				book.pages.AddLast(page);
			}
			return book;
		}
		public static LargeObjects.Book FactoryDsl(int i)
		{
			var book = new LargeObjects.Book
			{
				authorId = i / 100,
				published = i % 3 == 0 ? null : (DateTime?)NOW.AddMinutes(i).Date,
				title = "book title " + i
			};
			var genres = new List<LargeObjects.Genre>();
			for (int j = 0; j < i % 2; j++)
				genres.Add((LargeObjects.Genre)((i + j) % 4));
			book.genres = genres.ToArray();
			for (int j = 0; j < i % 20; j++)
				book.changes.Add(NOW.AddMinutes(i).Date);
			for (int j = 0; j < i % 50; j++)
				book.metadata["key " + i + j] = "value " + i + j;
			if (i % 3 == 0 || i % 7 == 0) book.cover = ILLUSTRATIONS[i % ILLUSTRATIONS.Count];
			var sb = new StringBuilder();
			for (int j = 0; j < i % 1000; j++)
			{
				sb.Append("some text on page " + j);
				sb.Append("more text for " + i);
				var page = new LargeObjects.Page
				{
					text = sb.ToString(),
					BookID = book.ID, //TODO: we should not be updating this, but since it's never persisted, it never gets updated
					Index = j
				};
				for (int z = 0; z < i % 100; z++)
				{
					LargeObjects.Note note;
					if (z % 3 == 0)
						note = new LargeObjects.Headnote { modifiedAt = NOW.AddSeconds(i), note = "headnote " + j + " at " + z };
					else
						note = new LargeObjects.Footnote { createadAt = NOW.AddSeconds(i), note = "footnote " + j + " at " + z, index = i };
					if (z % 3 == 0)
						note.writtenBy = "author " + j + " " + z;
					page.notes.Add(note);
				}
				book.pages.AddLast(page);
			}
			return book;
		}
	}
	[DataContract]
	public enum Genre
	{
		[DataMember]
		Action,
		[DataMember]
		Romance,
		[DataMember]
		Comedy,
		[DataMember]
		SciFi
	}
	[DataContract]
	public class Page
	{
		public Page()
		{
			notes = new List<Note>();
		}
		[DataMember]
		public string URI { get; set; }
		[DataMember]
		public int BookID { get; set; }
		[DataMember]
		public int Index { get; set; }
		[DataMember]
		public string text { get; set; }
		[DataMember]
		public List<Note> notes { get; set; }
		[DataMember]
		public Guid identity { get; set; }
		public override int GetHashCode() { return URI.GetHashCode(); }
		public override bool Equals(object obj)
		{
			var other = obj as Page;
			return other != null && other.URI == this.URI && other.BookID == this.BookID && other.Index == this.Index
				&& other.text == this.text
				&& Enumerable.SequenceEqual(other.notes, this.notes);
		}
	}
	[DataContract]
	public struct Footnote : Note
	{
		[DataMember]
		public string note { get; set; }
		[DataMember]
		public string writtenBy { get; set; }
		[DataMember]
		public DateTime createadAt { get; set; }
		[DataMember]
		public long index { get; set; }
	}
	[DataContract]
	public struct Headnote : Note
	{
		[DataMember]
		public string note { get; set; }
		[DataMember]
		public string writtenBy { get; set; }
		[DataMember]
		public DateTime? modifiedAt { get; set; }
	}
	public interface Note
	{
		string note { get; set; }
		string writtenBy { get; set; }
	}
}
