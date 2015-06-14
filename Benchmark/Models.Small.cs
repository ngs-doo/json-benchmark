using System;
using System.Runtime.Serialization;

namespace JsonBenchmark.Models.Small
{
	[DataContract]
	public class Message : IEquatable<Message>
	{
		[DataMember(Order = 1)]
		public string message { get; set; }
		[DataMember(Order = 2)]
		public int version { get; set; }
		public override int GetHashCode() { return version; }
		public override bool Equals(object obj) { return base.Equals(obj as Message); }
		public bool Equals(Message other)
		{
			return other != null && other.message == this.message && other.version == this.version;
		}
		public static T Factory<T>(int i) where T : new()
		{
			dynamic instance = new T();
			instance.message = "some message " + i;
			instance.version = i;
			return instance;
		}
	}
	[DataContract]
	public class Complex : IEquatable<Complex>
	{
		[DataMember(Order = 1)]
		public decimal x { get; set; }
		[DataMember(Order = 2)]
		public float y { get; set; }
		[DataMember(Order = 3)]
		public long z { get; set; }
		public override int GetHashCode() { return (int)z; }
		public override bool Equals(object obj) { return Equals(obj as Complex); }
		public bool Equals(Complex other)
		{
			return other != null && other.x == this.x && other.y == this.y && other.z == this.z;
		}
		public static T Factory<T>(int i) where T : new()
		{
			dynamic instance = new T();
			instance.x = i / 1000m;
			instance.y = -i / 1000f;
			instance.z = i;
			return instance;
		}
	}
	[DataContract]
	public class Post : IEquatable<Post>
	{
		private static DateTime NOW = DateTime.UtcNow;

		[DataMember(Order = 2)]
		public Guid ID { get; set; }
		[DataMember(Order = 3)]
		public string title { get; set; }
		[DataMember(Order = 4)]
		public bool active { get; set; }
		[DataMember(Order = 5)]
		public DateTime created { get; set; }
		public override int GetHashCode() { return ID.GetHashCode(); }
		public override bool Equals(object obj) { return Equals(obj as Post); }
		public bool Equals(Post other)
		{
			return other != null && other.ID == this.ID && other.title == this.title
				&& other.active == this.active && other.created == this.created;
		}
		public static T Factory<T>(int i) where T : new()
		{
			dynamic instance = new T();
			instance.ID = Guid.NewGuid();
			instance.title = "some title " + i;
			instance.active = i % 2 == 0;
			instance.created = NOW.AddMinutes(i).Date;
			return instance;
		}
	}
}
