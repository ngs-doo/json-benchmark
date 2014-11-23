using Revenj.DomainPatterns;
using Revenj.Serialization;
using Revenj.Utility;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters;
using System.Text;

namespace JsonBenchmark
{
	class Program
	{
		enum BenchTarget
		{
			BakedInFull, BakedInMinimal, ProtoBuf, NewtonsoftJson
		}

		enum BenchSize
		{
			Small, Standard, Large
		}

		enum BenchType
		{
			Serialization, Both
		}

		static void Main(string[] args)
		{
			//args = new[] { "NewtonsoftJson", "Small", "Both", "1" };
			if (args.Length != 4)
			{
				Console.WriteLine(
					"Expected usage: JsonBenchamrk.exe ({0}) ({1}) ({2}) repeat",
					string.Join(" | ", Enum.GetNames(typeof(BenchTarget))),
					string.Join(" | ", Enum.GetNames(typeof(BenchSize))),
					string.Join(" | ", Enum.GetNames(typeof(BenchType))));
				return;
			}
			BenchTarget target;
			if (!Enum.TryParse<BenchTarget>(args[0], out target))
			{
				Console.WriteLine("Unknown target found: " + args[0] + ". Supported targets: " + string.Join(" | ", Enum.GetNames(typeof(BenchTarget))));
				return;
			}
			BenchSize size;
			if (!Enum.TryParse<BenchSize>(args[1], out size))
			{
				Console.WriteLine("Unknown size found: " + args[1] + ". Supported size: " + string.Join(" | ", Enum.GetNames(typeof(BenchSize))));
				return;
			}
			BenchType type;
			if (!Enum.TryParse<BenchType>(args[2], out type))
			{
				Console.WriteLine("Unknown type found: " + args[2] + ". Supported types: " + string.Join(" | ", Enum.GetNames(typeof(BenchType))));
				return;
			}
			int repeat;
			if (!int.TryParse(args[3], out repeat))
			{
				Console.WriteLine("Invalid repeat parameter: " + args[3]);
				return;
			}
			Action<object, ChunkedMemoryStream> serialize;
			Func<ChunkedMemoryStream, Type, object> deserialize;
			switch (target)
			{
				case BenchTarget.NewtonsoftJson:
					SetupNewtonsoftJson(out serialize, out deserialize);
					break;
				case BenchTarget.ProtoBuf:
					SetupRevenj(out serialize, out deserialize, "application/x-protobuf");
					break;
				case BenchTarget.BakedInFull:
					SetupRevenj(out serialize, out deserialize, "application/json");
					break;
				default:
					SetupRevenj(out serialize, out deserialize, "application/json;minimal");
					break;
			}
			switch (size)
			{
				case BenchSize.Small:
					try
					{
						TestSmall(repeat, serialize, deserialize, type);
					}
					catch (Exception ex)
					{
						ReportStatsAndRestart(null, -1, repeat);
						ReportStatsAndRestart(null, -1, repeat);
						ReportStatsAndRestart(null, -1, repeat);
						Console.WriteLine("error");
						Console.WriteLine(ex.ToString());
					}
					break;
				case BenchSize.Standard:
					try
					{
						TestStandard(repeat, serialize, deserialize, type);
					}
					catch (Exception ex)
					{
						ReportStatsAndRestart(null, -1, repeat);
						ReportStatsAndRestart(null, -1, repeat);
						Console.WriteLine("error");
						Console.WriteLine(ex.ToString());
					}
					break;
				default:
					try
					{
						TestLarge(repeat, serialize, deserialize, type);
					}
					catch (Exception ex)
					{
						ReportStatsAndRestart(null, -1, repeat);
						Console.WriteLine("error");
						Console.WriteLine(ex.ToString());
					}
					break;
			}
		}

		static void ReportStatsAndRestart(Stopwatch sw, long size, int incorrect)
		{
			Console.WriteLine("duration = " + (sw != null ? sw.ElapsedMilliseconds : -1));
			Console.WriteLine("size = " + size);
			Console.WriteLine("invalid deserialization = " + incorrect);
			if (sw != null)
				sw.Restart();
		}

		static void TestSmall(int repeat, Action<object, ChunkedMemoryStream> serialize, Func<ChunkedMemoryStream, Type, object> deserialize, BenchType type)
		{
			var ms = new ChunkedMemoryStream();
			var sw = Stopwatch.StartNew();
			int incorrect = 0;
			long size = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var message = new SmallObjects.Message { message = "some message " + i, version = i };
				serialize(message, ms);
				size += ms.Position;
				if (type == BenchType.Both)
				{
					ms.Position = 0;
					var deser = (SmallObjects.Message)deserialize(ms, typeof(SmallObjects.Message));
					if (!message.Equals(deser))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
			size = 0;
			incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var complex = new SmallObjects.Complex { x = i, y = -i };
				serialize(complex, ms);
				size += ms.Position;
				if (type == BenchType.Both)
				{
					ms.Position = 0;
					var deser = (SmallObjects.Complex)deserialize(ms, typeof(SmallObjects.Complex));
					if (!deser.Equals(complex))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
			size = 0;
			incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var post = new SmallObjects.Post { text = "some text for post " + i, title = "some title " + i, created = DateTime.Today.AddMinutes(i).Date };
				serialize(post, ms);
				size += ms.Position;
				if (type == BenchType.Both)
				{
					ms.Position = 0;
					var deser = (SmallObjects.Post)deserialize(ms, typeof(SmallObjects.Post));
					if (!deser.Equals(post))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
		}

		static void TestStandard(int repeat, Action<object, ChunkedMemoryStream> serialize, Func<ChunkedMemoryStream, Type, object> deserialize, BenchType type)
		{
			var ms = new ChunkedMemoryStream();
			int incorrect = 0;
			long size = 0;
			var now = DateTime.Now;
			var sw = Stopwatch.StartNew();
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var delete = new StandardObjects.DeletePost { postID = i, deletedBy = i / 100, lastModified = now.AddSeconds(i), reason = "no reason" };
				serialize(delete, ms);
				size += ms.Position;
				if (type == BenchType.Both)
				{
					ms.Position = 0;
					var deser = (StandardObjects.DeletePost)deserialize(ms, typeof(StandardObjects.DeletePost));
					if (!delete.Equals(deser))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
			size = 0;
			incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var post = new StandardObjects.Post
				{
					approved = now.AddMilliseconds(i),
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
							approved = j % 2 == 0 ? null : (DateTime?)now.AddMilliseconds(i),
							state = (StandardObjects.CommentState)(j % 3),
							user = "some random user " + i,
							PostID = post.ID, //TODO: we should not be updating this, but since it's never persisted, it never gets updated
							Index = j
						});
				}
				serialize(post, ms);
				size += ms.Position;
				if (type == BenchType.Both)
				{
					ms.Position = 0;
					var deser = (StandardObjects.Post)deserialize(ms, typeof(StandardObjects.Post));
					if (!post.Equals(deser))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
		}

		static void TestLarge(int repeat, Action<object, ChunkedMemoryStream> serialize, Func<ChunkedMemoryStream, Type, object> deserialize, BenchType type)
		{
			var ms = new ChunkedMemoryStream();
			var illustrations = new List<byte[]>();
			var rnd = new Random(1);
			var now = DateTime.Now;
			long size = 0;
			for (int i = 0; i < 10; i++)
			{
				var buf = new byte[256 * i * i * i];
				rnd.NextBytes(buf);
				illustrations.Add(buf);
			}
			var sw = Stopwatch.StartNew();
			int incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var book = new LargeObjects.Book
				{
					authorId = i / 100,
					published = i % 3 == 0 ? null : (DateTime?)now.AddMinutes(i).Date,
					title = "book title " + i
				};
				var genres = new List<LargeObjects.Genre>();
				for (int j = 0; j < i % 2; j++)
					genres.Add((LargeObjects.Genre)((i + j) % 4));
				book.genres = genres.ToArray();
				for (int j = 0; j < i % 20; j++)
					book.changes.Add(now.AddMinutes(i).Date);
				for (int j = 0; j < i % 50; j++)
					book.metadata["key " + i + j] = "value " + i + j;
				if (i % 3 == 0 || i % 7 == 0) book.cover = illustrations[i % illustrations.Count];
				var sb = new StringBuilder();
				for (int j = 0; j < i % 100; j++)
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
							note = new LargeObjects.Headnote { modifiedAt = now.AddSeconds(i), note = "headnote " + j + " at " + z };
						else
							note = new LargeObjects.Footnote { createadAt = now.AddSeconds(i), note = "footnote " + j + " at " + z, index = i };
						if (z % 3 == 0)
							note.writtenBy = "author " + j + " " + z;
						page.notes.Add(note);
					}
					book.pages.AddLast(page);
				}
				serialize(book, ms);
				size += ms.Position;
				if (type == BenchType.Both)
				{
					ms.Position = 0;
					var deser = (LargeObjects.Book)deserialize(ms, typeof(LargeObjects.Book));
					if (!book.Equals(deser))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
		}

		static void SetupRevenj(out Action<object, ChunkedMemoryStream> serialize, out Func<ChunkedMemoryStream, Type, object> deserialize, string contentType)
		{
			IServiceLocator locator = DSL.Core.SetupPostgres(ConfigurationManager.AppSettings["ConnectionString"]);
			IWireSerialization serialization = locator.Resolve<IWireSerialization>();
			serialize = (obj, stream) => serialization.Serialize(obj, contentType, stream);
			deserialize = (stream, type) => serialization.Deserialize(stream, type, contentType, default(StreamingContext));
		}

		static void SetupNewtonsoftJson(out Action<object, ChunkedMemoryStream> serialize, out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			var serializer = new Newtonsoft.Json.JsonSerializer();
			serializer.TypeNameAssemblyFormat = FormatterAssemblyStyle.Simple;
			serializer.TypeNameHandling = Newtonsoft.Json.TypeNameHandling.Auto;
			serialize = (obj, stream) =>
			{
				var sw = stream.GetWriter();
				serializer.Serialize(sw, obj);
				sw.Flush();
			};
			deserialize = (stream, type) => serializer.Deserialize(stream.GetReader(), type);
		}
	}
}
