using System;
using System.Linq;

namespace SmallObjects.Bond
{
	partial class Message : IEquatable<Message>
	{
		public bool Equals(Message other)
		{
			return other != null && other.message == this.message && other.version == this.version;
		}
	}
	partial class Complex : IEquatable<Complex>
	{
		public bool Equals(Complex other)
		{
			return other != null && other.x == this.x && other.y == this.y && other.z == this.z;
		}
	}
	partial class Post : IEquatable<Post>
	{
		public bool Equals(Post other)
		{
			return other != null && other.ID == this.ID && other.created == this.created
				&& other.title == this.title && other.active == this.active;
		}
	}
	public static class BondTypeAliasConverter
	{
		public static decimal Convert(ArraySegment<byte> value, decimal unused)
		{
			var bits = new int[value.Count / sizeof(int)];
			Buffer.BlockCopy(value.Array, value.Offset, bits, 0, bits.Length * sizeof(int));
			return new decimal(bits);
		}

		public static ArraySegment<byte> Convert(decimal value, ArraySegment<byte> unused)
		{
			var bits = decimal.GetBits(value);
			var data = new byte[bits.Length * sizeof(int)];
			Buffer.BlockCopy(bits, 0, data, 0, data.Length);
			return new ArraySegment<byte>(data);
		}
		public static long Convert(DateTime value, long unused)
		{
			return value.Ticks;
		}

		public static DateTime Convert(long value, DateTime unused)
		{
			return new DateTime(value);
		}
		public static Guid Convert(ArraySegment<byte> value, Guid unused)
		{
			var bytes = new byte[value.Count];
			Array.Copy(value.Array, value.Offset, bytes, 0, bytes.Length);
			return new Guid(bytes);
		}

		public static ArraySegment<byte> Convert(Guid value, ArraySegment<byte> unused)
		{
			var bytes = value.ToByteArray();
			return new ArraySegment<byte>(bytes);
		}
	}
}
namespace StandardObjects.Bond
{
	partial class Vote : IEquatable<Vote>
	{
		public bool Equals(Vote other)
		{
			return other != null && other.upvote == this.upvote && other.downvote == this.downvote;
		}
	}
	partial class Comment : IEquatable<Comment>
	{
		public bool Equals(Comment other)
		{
			return other != null
				&& other.created == this.created && other.approved == this.approved && other.user == this.user
				&& other.message == this.message && other.votes.Equals(this.votes);
		}
	}
	partial class DeletePost : IEquatable<DeletePost>
	{
		public bool Equals(DeletePost other)
		{
			return other != null && other.postID == this.postID && other.referenceId == this.referenceId
				&& other.lastModified == this.lastModified && other.deletedBy == this.deletedBy
				&& other.reason == this.reason
				&& (other.versions == this.versions || other.versions != null && Enumerable.SequenceEqual(other.versions, this.versions))
				&& other.state == this.state
				&& (other.votes == this.votes || other.votes != null && Enumerable.SequenceEqual(other.votes, this.votes));
		}
	}
	partial class Post : IEquatable<Post>
	{
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
	}
	public static class BondTypeAliasConverter
	{
		public static decimal Convert(ArraySegment<byte> value, decimal unused)
		{
			var bits = new int[value.Count / sizeof(int)];
			Buffer.BlockCopy(value.Array, value.Offset, bits, 0, bits.Length * sizeof(int));
			return new decimal(bits);
		}

		public static ArraySegment<byte> Convert(decimal value, ArraySegment<byte> unused)
		{
			var bits = decimal.GetBits(value);
			var data = new byte[bits.Length * sizeof(int)];
			Buffer.BlockCopy(bits, 0, data, 0, data.Length);
			return new ArraySegment<byte>(data);
		}
		public static long Convert(DateTime value, long unused)
		{
			return value.Ticks;
		}

		public static DateTime Convert(long value, DateTime unused)
		{
			return new DateTime(value);
		}
		public static Guid Convert(ArraySegment<byte> value, Guid unused)
		{
			var bytes = new byte[value.Count];
			Array.Copy(value.Array, value.Offset, bytes, 0, bytes.Length);
			return new Guid(bytes);
		}

		public static ArraySegment<byte> Convert(Guid value, ArraySegment<byte> unused)
		{
			var bytes = value.ToByteArray();
			return new ArraySegment<byte>(bytes);
		}
	}

}