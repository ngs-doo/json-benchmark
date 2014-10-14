using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters;
using System.Text;
using Revenj.DomainPatterns;
using Revenj.Serialization;
using Revenj.Utility;

namespace JsonBenchmark
{
	class Program
	{
		enum BenchTarget
		{
			RevenjJson, ServiceStack, Jil, JsonNet, RevenjProtoBuf
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
			//args = new[] { "ServiceStack", "Small", "Both", "1" };
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
			Action<object, Stream> serialize;
			Func<Stream, Type, object> deserialize;
			switch (target)
			{
				case BenchTarget.JsonNet:
					SetupJsonNet(out serialize, out deserialize);
					break;
				case BenchTarget.Jil:
					SetupJil(out serialize, out deserialize);
					break;
				case BenchTarget.ServiceStack:
					SetupServiceStack(out serialize, out deserialize);
					break;
				case BenchTarget.RevenjProtoBuf:
					SetupRevenj(out serialize, out deserialize, true);
					break;
				default:
					SetupRevenj(out serialize, out deserialize, false);
					break;
			}
			switch (size)
			{
				case BenchSize.Small:
					try
					{
						TestSmall(repeat, serialize, deserialize, type);
					}
					catch
					{
						ReportStatsAndRestart(null, null, repeat);
						ReportStatsAndRestart(null, null, repeat);
						ReportStatsAndRestart(null, null, repeat);
					}
					break;
				case BenchSize.Standard:
					try
					{
						TestStandard(repeat, serialize, deserialize, type);
					}
					catch
					{
						ReportStatsAndRestart(null, null, repeat);
						ReportStatsAndRestart(null, null, repeat);
					}
					break;
				default:
					try
					{
						TestLarge(repeat, serialize, deserialize, type);
					}
					catch
					{
						ReportStatsAndRestart(null, null, repeat);
					}
					break;
			}
		}

		static void ReportStatsAndRestart(Stopwatch sw, Stream stream, int incorrect)
		{
			Console.WriteLine("duration = " + (sw != null ? sw.ElapsedMilliseconds : -1));
			Console.WriteLine("size = " + (stream != null ? stream.Position : -1));
			Console.WriteLine("invalid deserialization = " + incorrect);
			if (sw != null)
				sw.Restart();
		}

		static void TestSmall(int repeat, Action<object, Stream> serialize, Func<Stream, Type, object> deserialize, BenchType type)
		{
			var ms = new MemoryStream();
			var sw = Stopwatch.StartNew();
			int incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var message = new SmallObjects.Message { message = "some message " + i };
				serialize(message, ms);
				if (type == BenchType.Both)
				{
					ms.Position = 0;
					var deser = (SmallObjects.Message)deserialize(ms, typeof(SmallObjects.Message));
					if (message.URI != deser.URI || message.message != deser.message
						|| message.ProcessedAt != deser.ProcessedAt || message.QueuedAt != deser.QueuedAt)
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, ms, incorrect);
			incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var complex = new SmallObjects.Complex { x = i, y = -i };
				serialize(complex, ms);
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
			ReportStatsAndRestart(sw, ms, incorrect);
			incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var post = new SmallObjects.Post { text = "some text for post " + i, title = "some title " + i, created = DateTime.Today.AddMinutes(i).Date };
				serialize(post, ms);
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
			ReportStatsAndRestart(sw, ms, incorrect);
		}

		static void TestStandard(int repeat, Action<object, Stream> serialize, Func<Stream, Type, object> deserialize, BenchType type)
		{
			var ms = new ChunkedMemoryStream();
			var sw = Stopwatch.StartNew();
			int incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var post = new StandardObjects.Post
				{
					approved = DateTime.Now.AddMilliseconds(i),
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
							PostID = post.ID, //TODO: we should not be updating this, but since it's never persisted, it never gets updated
							Index = j
						});
				}
				var delete = new StandardObjects.DeletePost { post = post, reason = "no reason" };
				serialize(delete, ms);
				if (type == BenchType.Both)
				{
					ms.Position = 0;
					var deser = (StandardObjects.DeletePost)deserialize(ms, typeof(StandardObjects.DeletePost));
					if (delete.URI != deser.URI || delete.reason != deser.reason || !delete.post.Equals(deser.post)
						|| delete.ProcessedAt != deser.ProcessedAt || delete.QueuedAt != deser.QueuedAt)
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, ms, incorrect);
			incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var post = new StandardObjects.Post
				{
					approved = DateTime.Now.AddMilliseconds(i),
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
							approved = j % 2 == 0 ? null : (DateTime?)DateTime.Now.AddMilliseconds(i),
							state = (StandardObjects.CommentState)(j % 3),
							user = "some random user " + i,
							PostID = post.ID, //TODO: we should not be updating this, but since it's never persisted, it never gets updated
							Index = j
						});
				}
				serialize(post, ms);
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
			ReportStatsAndRestart(sw, ms, incorrect);
		}

		static void TestLarge(int repeat, Action<object, Stream> serialize, Func<Stream, Type, object> deserialize, BenchType type)
		{
			var ms = new ChunkedMemoryStream();
			var sw = Stopwatch.StartNew();
			var illustrations = new List<byte[]>();
			var rnd = new Random(1);
			for (int i = 0; i < 10; i++)
			{
				var buf = new byte[2096 * i * i];
				rnd.NextBytes(buf);
				illustrations.Add(buf);
			}
			int incorrect = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var book = new LargeObjects.Book
				{
					authorId = i / 100,
					published = i % 3 == 0 ? null : (DateTime?)DateTime.Now.AddMinutes(i).Date,
					title = "book title " + i
				};
				for (int j = 0; j < i % 20; j++)
					book.changes.Add(DateTime.Now.AddMinutes(i).Date);
				for (int j = 0; j < i % 50; j++)
					book.metadata["key " + i + j] = "value " + i + j;
				if (i % 2 == 0) book.frontCover = illustrations[i % illustrations.Count];
				if (i % 3 == 0) book.backCover = illustrations[i % illustrations.Count];
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
					for (int z = 0; z < i % 10; z++)
					{
						page.illustrations.Add(illustrations[z]);
					}
					for (int z = 0; z < i % 100; z++)
					{
						if (z % 3 == 0)
							page.notes.Add(new LargeObjects.Headnote { modifiedAt = DateTime.Now.AddSeconds(i), note = "headnote " + j + " at " + z });
						else
							page.notes.Add(new LargeObjects.Footnote { createadAt = DateTime.Now.AddSeconds(i), note = "footnote " + j + " at " + z, index = i });
					}
					book.pages.Add(page);
				}
				serialize(book, ms);
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
			ReportStatsAndRestart(sw, ms, incorrect);
		}

		static void SetupRevenj(out Action<object, Stream> serialize, out Func<Stream, Type, object> deserialize, bool protobuf)
		{
			var contentType = protobuf ? "application/x-protobuf" : "application/json";
			IServiceLocator locator = DSL.Core.SetupPostgres(ConfigurationManager.AppSettings["ConnectionString"]);
			IWireSerialization serialization = locator.Resolve<IWireSerialization>();
			serialize = (obj, stream) => serialization.Serialize(obj, contentType, stream);
			deserialize = (stream, type) => serialization.Deserialize(stream, type, contentType, default(StreamingContext));
		}

		static void SetupJsonNet(out Action<object, Stream> serialize, out Func<Stream, Type, object> deserialize)
		{
			var serializer = new Newtonsoft.Json.JsonSerializer();
			serializer.TypeNameAssemblyFormat = FormatterAssemblyStyle.Simple;
			serializer.TypeNameHandling = Newtonsoft.Json.TypeNameHandling.Auto;
			serialize = (obj, stream) =>
			{
				var sw = new StreamWriter(stream);
				serializer.Serialize(sw, obj);
				sw.Flush();
			};
			deserialize = (stream, type) => serializer.Deserialize(new StreamReader(stream), type);
		}

		static void SetupServiceStack(out Action<object, Stream> serialize, out Func<Stream, Type, object> deserialize)
		{
			serialize = (obj, stream) =>
			{
				var sw = new StreamWriter(stream);
				ServiceStack.Text.TypeSerializer.SerializeToWriter(obj, sw);
				sw.Flush();
			};
			deserialize = (stream, type) => ServiceStack.Text.TypeSerializer.DeserializeFromReader(new StreamReader(stream), type);
		}

		static void SetupJil(out Action<object, Stream> serialize, out Func<Stream, Type, object> deserialize)
		{
			//serialize = null;
			//deserialize = null;
			serialize = (obj, stream) =>
			{
				var sw = new StreamWriter(stream);
				Jil.JSON.Serialize(obj, sw);
				sw.Flush();
			};
			deserialize = (stream, type) => Jil.JSON.Deserialize(new StreamReader(stream), type);
		}
	}
}
