using Revenj.Extensibility;
using Revenj.Serialization;
using Revenj.Utility;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters;
using System.Text;

namespace JsonBenchmark
{
	class Program
	{
		enum BenchTarget
		{
			BakedInFull, BakedInMinimal, ProtoBuf, NewtonsoftJson, Jil, fastJSON, ServiceStack
		}

		enum BenchSize
		{
			Small, Standard, Large
		}

		enum BenchType
		{
			Serialization, Both, None, Check
		}

		static void Main(string[] args)
		{
			//args = new[] { "ProtoBuf", "Standard", "Check", "100" };
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
				case BenchTarget.Jil:
					SetupJil(out serialize, out deserialize);
					break;
				case BenchTarget.fastJSON:
					SetupFastJson(out serialize, out deserialize);
					break;
				case BenchTarget.ServiceStack:
					SetupServiceStack(out serialize, out deserialize);
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
			var now = DateTime.UtcNow;
			var sw = Stopwatch.StartNew();
			int incorrect = 0;
			long size = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var message = new SmallObjects.Message { message = "some message " + i, version = i };
				if (type == BenchType.None) continue;
				serialize(message, ms);
				size += ms.Position;
				if (type == BenchType.Both || type == BenchType.Check)
				{
					ms.Position = 0;
					var deser = (SmallObjects.Message)deserialize(ms, typeof(SmallObjects.Message));
					if (type == BenchType.Check && !message.Equals(deser))
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
				var complex = new SmallObjects.Complex { x = i / 1000m, y = -i / 1000f, z = i };
				if (type == BenchType.None) continue;
				serialize(complex, ms);
				size += ms.Position;
				if (type == BenchType.Both || type == BenchType.Check)
				{
					ms.Position = 0;
					var deser = (SmallObjects.Complex)deserialize(ms, typeof(SmallObjects.Complex));
					if (type == BenchType.Check && !deser.Equals(complex))
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
				var post = new SmallObjects.Post { title = "some title " + i, active = i % 2 == 0, created = now.AddMinutes(i).Date };
				if (type == BenchType.None) continue;
				serialize(post, ms);
				size += ms.Position;
				if (type == BenchType.Both || type == BenchType.Check)
				{
					ms.Position = 0;
					var deser = (SmallObjects.Post)deserialize(ms, typeof(SmallObjects.Post));
					if (type == BenchType.Check && !deser.Equals(post))
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
			var now = DateTime.UtcNow;
			var guids = Enumerable.Range(0, 100).Select(it => Guid.NewGuid()).ToArray();
			var sw = Stopwatch.StartNew();
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var delete = new StandardObjects.DeletePost { postID = i, deletedBy = i / 100, lastModified = now.AddSeconds(i), reason = "no reason" };
				if (i % 3 == 0) delete.referenceId = guids[i % 100];
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
				if (type == BenchType.None) continue;
				serialize(delete, ms);
				size += ms.Position;
				if (type == BenchType.Both || type == BenchType.Check)
				{
					ms.Position = 0;
					var deser = (StandardObjects.DeletePost)deserialize(ms, typeof(StandardObjects.DeletePost));
					if (type == BenchType.Check && !delete.Equals(deser))
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
					approved = i % 2 == 0 ? null : (DateTime?)now.AddMilliseconds(i),
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
							approved = j % 3 != 0 ? null : (DateTime?)now.AddMilliseconds(i),
							user = "some random user " + i,
							PostID = post.ID, //TODO: we should not be updating this, but since it's never persisted, it never gets updated
							Index = j
						});
				}
				if (type == BenchType.None) continue;
				serialize(post, ms);
				size += ms.Position;
				if (type == BenchType.Both || type == BenchType.Check)
				{
					ms.Position = 0;
					var deser = (StandardObjects.Post)deserialize(ms, typeof(StandardObjects.Post));
					if (type == BenchType.Check && !post.Equals(deser))
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
			var now = DateTime.UtcNow;
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
							note = new LargeObjects.Headnote { modifiedAt = now.AddSeconds(i), note = "headnote " + j + " at " + z };
						else
							note = new LargeObjects.Footnote { createadAt = now.AddSeconds(i), note = "footnote " + j + " at " + z, index = i };
						if (z % 3 == 0)
							note.writtenBy = "author " + j + " " + z;
						page.notes.Add(note);
					}
					book.pages.AddLast(page);
				}
				if (type == BenchType.None) continue;
				serialize(book, ms);
				size += ms.Position;
				if (type == BenchType.Both || type == BenchType.Check)
				{
					ms.Position = 0;
					var deser = (LargeObjects.Book)deserialize(ms, typeof(LargeObjects.Book));
					if (type == BenchType.Check && !book.Equals(deser))
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
			var binder = new GenericDeserializationBinder(new Lazy<ITypeResolver>(() => null));
			IWireSerialization serialization = new WireSerialization(binder);
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
				var sw = new Newtonsoft.Json.JsonTextWriter(stream.GetWriter());
				serializer.Serialize(sw, obj);
				sw.Flush();
			};
			deserialize = (stream, type) => serializer.Deserialize(new Newtonsoft.Json.JsonTextReader(stream.GetReader()), type);
		}

		static void SetupJil(out Action<object, ChunkedMemoryStream> serialize, out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			serialize = (obj, stream) =>
			{
				var sw = stream.GetWriter();
				Jil.JSON.Serialize(obj, sw);
				sw.Flush();
			};
			deserialize = (stream, type) => Jil.JSON.Deserialize(stream.GetReader(), type);
		}

		static void SetupFastJson(out Action<object, ChunkedMemoryStream> serialize, out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			serialize = (obj, stream) =>
			{
				var sw = stream.GetWriter();
				sw.Write(fastJSON.JSON.ToJSON(obj));
				sw.Flush();
			};
			deserialize = (stream, type) => fastJSON.JSON.ToObject(stream.GetReader().ReadToEnd(), type);
		}

		static void SetupServiceStack(out Action<object, ChunkedMemoryStream> serialize, out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			serialize = (obj, stream) => ServiceStack.Text.JsonSerializer.SerializeToStream(obj, stream);
			deserialize = (stream, type) => ServiceStack.Text.JsonSerializer.DeserializeFromStream(type, stream);
		}
	}
}
