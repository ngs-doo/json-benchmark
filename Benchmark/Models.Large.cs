using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;

namespace JsonBenchmark.Models.Large
{
	[DataContract]
	public class Book : IEquatable<Book>
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
			cover = new byte[0];//otherwise buggy ProtoBuf and some other libs
		}
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
		public override int GetHashCode() { return ID; }
		public override bool Equals(object obj) { return Equals(obj as Book); }
		public bool Equals(Book other)
		{
			var otherChanges = other != null ? other.changes.ToList() : null;
			var thisChanges = changes.ToList();
			if (otherChanges != null) otherChanges.Sort();
			thisChanges.Sort();
			var otherKeys = other != null ? other.metadata.Keys.ToList() : null;
			var thisKeys = this.metadata.Keys.ToList();
			if (otherKeys != null) otherKeys.Sort();
			thisKeys.Sort();
			return other != null && other.ID == this.ID && other.title == this.title
				&& other.authorId == this.authorId
				&& other.pages != null && Enumerable.SequenceEqual(other.pages, this.pages)
				&& other.published == this.published
				&& other.cover != null && Enumerable.SequenceEqual(other.cover, this.cover)
				&& otherChanges != null && Enumerable.SequenceEqual(otherChanges, thisChanges)
				&& otherKeys != null && Enumerable.SequenceEqual(otherKeys, thisKeys)
				&& otherKeys.All(it => other.metadata[it] == this.metadata[it])
				&& other.genres != null && Enumerable.SequenceEqual(other.genres, this.genres);
		}
		public static TB Factory<TB, TG, TP, TH, TF>(int i, Func<int, TG> cast)
			where TB : new()
			where TG : struct
			where TP : new()
			where TH : new()
			where TF : new()
		{
			dynamic book = new TB();
			book.ID = -i;
			book.authorId = i / 100;
			book.published = i % 3 == 0 ? null : (DateTime?)NOW.AddMinutes(i).Date;
			book.title = "book title " + i;
			var genres = new TG[i % 2];
			for (int j = 0; j < i % 2; j++)
				genres[j] = cast((i + j) % 4);
			book.genres = genres;
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
				dynamic page = new TP();
				page.text = sb.ToString();
				for (int z = 0; z < i % 100; z++)
				{
					dynamic note;
					if (z % 3 == 0)
					{
						note = new TH();
						note.modifiedAt = NOW.AddSeconds(i);
						note.note = "headnote " + j + " at " + z;
					}
					else
					{
						note = new TF();
						note.createadAt = NOW.AddSeconds(i);
						note.note = "footnote " + j + " at " + z;
						note.index = i;
					}
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
	public class Page : IEquatable<Page>
	{
		public Page()
		{
			notes = new List<Note>();
		}
		[DataMember]
		public string text { get; set; }
		[DataMember]
		public List<Note> notes { get; set; }
		[DataMember]
		public Guid identity { get; set; }
		public override int GetHashCode() { return identity.GetHashCode(); }
		public override bool Equals(object obj) { return Equals(obj as Page); }
		public bool Equals(Page other)
		{
			return other != null
				&& other.text == this.text
				&& Enumerable.SequenceEqual(other.notes, this.notes)
				&& other.identity == this.identity;
		}
	}
	[DataContract]
	public class Footnote : Note, IEquatable<Footnote>
	{
		[DataMember]
		public string note { get; set; }
		[DataMember]
		public string writtenBy { get; set; }
		[DataMember]
		public DateTime createadAt { get; set; }
		[DataMember]
		public long index { get; set; }
		public override int GetHashCode() { return (int)index; }
		public override bool Equals(object obj) { return Equals(obj as Footnote); }
		public bool Equals(Footnote other)
		{
			return other != null && other.note == this.note && other.writtenBy == this.writtenBy
				&& other.createadAt == this.createadAt && other.index == this.index;
		}
	}
	[DataContract]
	public class Headnote : Note, IEquatable<Headnote>
	{
		[DataMember]
		public string note { get; set; }
		[DataMember]
		public string writtenBy { get; set; }
		[DataMember]
		public DateTime? modifiedAt { get; set; }
		public override int GetHashCode() { return (modifiedAt ?? DateTime.MinValue).GetHashCode(); }
		public override bool Equals(object obj) { return Equals(obj as Headnote); }
		public bool Equals(Headnote other)
		{
			return other != null && other.note == this.note && other.writtenBy == this.writtenBy
				&& other.modifiedAt == this.modifiedAt;
		}
	}
	public interface Note
	{
		string note { get; set; }
		string writtenBy { get; set; }
	}
}
