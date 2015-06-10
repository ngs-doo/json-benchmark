using Bond.IO.Unsafe;
using Bond.Protocols;
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
			BakedInFull, BakedInMinimal, ProtoBuf, NewtonsoftJson, Jil, fastJSON, ServiceStack, BondJson, BondBinary
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
			//args = new[] { "ProtoBuf", "Small", "Serialization", "1000000" };
			//args = new[] { "BakedInMinimal", "Small", "Check", "1000" };
			//args = new[] { "BondJson", "Small", "Both", "100000" };
			//args = new[] { "BondBinary", "Small", "Both", "100" };
			//args = new[] { "Jil", "Small", "Serialization", "10000000" };
			//args = new[] { "NewtonsoftJson", "Small", "Serialization", "10000000" };
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
				case BenchTarget.BondJson:
					SetupBondJson(out serialize, out deserialize);
					break;
				case BenchTarget.BondBinary:
					SetupBondBinary(out serialize, out deserialize);
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
						if (target == BenchTarget.BondBinary || target == BenchTarget.BondJson)
						{
							TestSmallBond(repeat, type, serialize, deserialize);
						}
						else
						{
							TestSmall(repeat, serialize, deserialize, type);
						}
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

		private static void RunLoop<T>(
			int repeat,
			Action<object, ChunkedMemoryStream> serialize,
			Func<ChunkedMemoryStream, Type, object> deserialize,
			BenchType type,
			ChunkedMemoryStream ms,
			Func<int, T> factory)
		{
			var sw = Stopwatch.StartNew();
			var incorrect = 0;
			long size = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var message = factory(i);
				if (type == BenchType.None) continue;
				serialize(message, ms);
				size += ms.Position;
				if (type == BenchType.Both || type == BenchType.Check)
				{
					ms.Position = 0;
					var deser = (T)deserialize(ms, typeof(T));
					if (type == BenchType.Check && !message.Equals(deser))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
		}

		static void TestSmall(
			int repeat,
			Action<object, ChunkedMemoryStream> serialize,
			Func<ChunkedMemoryStream, Type, object> deserialize,
			BenchType type)
		{
			var ms = new ChunkedMemoryStream();
			var now = DateTime.UtcNow;
			RunLoop(repeat, serialize, deserialize, type, ms, i => new SmallObjects.Message { message = "some message " + i, version = i });
			RunLoop(repeat, serialize, deserialize, type, ms, i => new SmallObjects.Complex { x = i / 1000m, y = -i / 1000f, z = i });
			RunLoop(repeat, serialize, deserialize, type, ms, i => new SmallObjects.Post { title = "some title " + i, active = i % 2 == 0, created = now.AddMinutes(i).Date });
		}

		static void TestSmallBond(
			int repeat,
			BenchType type,
			Action<object, ChunkedMemoryStream> serialize,
			Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			var ms = new ChunkedMemoryStream();
			var now = DateTime.UtcNow;
			RunLoop(repeat, serialize, deserialize, type, ms, i => new SmallObjects.Bond.Message { message = "some message " + i, version = i });
			RunLoop(repeat, serialize, deserialize, type, ms, i => new SmallObjects.Bond.Complex { x = i / 1000m, y = -i / 1000f, z = i });
			RunLoop(repeat, serialize, deserialize, type, ms, i =>
				new SmallObjects.Bond.Post
				{
					URI = new object().GetHashCode().ToString(),
					ID = SmallObjects.Bond.BondTypeAliasConverter.Convert(Guid.NewGuid(), new SmallObjects.Bond.GUID()),
					title = "some title " + i,
					active = i % 2 == 0,
					created = now.AddMinutes(i).Date
				}
			);
		}

		static void TestStandard(int repeat, Action<object, ChunkedMemoryStream> serialize, Func<ChunkedMemoryStream, Type, object> deserialize, BenchType type)
		{
			var ms = new ChunkedMemoryStream();
			var now = DateTime.UtcNow;
			var guids = Enumerable.Range(0, 100).Select(it => Guid.NewGuid()).ToArray();
			RunLoop(repeat, serialize, deserialize, type, ms, i =>
			{
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
				return delete;
			});
			RunLoop(repeat, serialize, deserialize, type, ms, i =>
			{
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
				return post;
			});
		}

		static void TestLarge(int repeat, Action<object, ChunkedMemoryStream> serialize, Func<ChunkedMemoryStream, Type, object> deserialize, BenchType type)
		{
			var ms = new ChunkedMemoryStream();
			var illustrations = new List<byte[]>();
			var rnd = new Random(1);
			var now = DateTime.UtcNow;
			for (int i = 0; i < 10; i++)
			{
				var buf = new byte[256 * i * i * i];
				rnd.NextBytes(buf);
				illustrations.Add(buf);
			}
			RunLoop(repeat, serialize, deserialize, type, ms, i =>
			{
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
				return book;
			});
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

		static void SetupBondJson(out Action<object, ChunkedMemoryStream> serialize, out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			var serializers = new Dictionary<Type, Bond.Serializer<SimpleJsonWriter>>();
			var deserializers = new Dictionary<Type, Bond.Deserializer<SimpleJsonReader>>();
			foreach (var t in new[] { typeof(SmallObjects.Bond.Message), typeof(SmallObjects.Bond.Complex), typeof(SmallObjects.Bond.Post) })
			{
				serializers[t] = new Bond.Serializer<SimpleJsonWriter>(t);
				deserializers[t] = new Bond.Deserializer<SimpleJsonReader>(t);
			}
			serialize = (obj, stream) =>
			{
				var jsonWriter = new SimpleJsonWriter(stream);
				serializers[obj.GetType()].Serialize(obj, jsonWriter);
				jsonWriter.Flush();
			};
			deserialize = (stream, type) =>
			{
				var reader = new SimpleJsonReader(stream);
				return deserializers[type].Deserialize(reader);
			};
		}

		static void SetupBondBinary(out Action<object, ChunkedMemoryStream> serialize, out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			var serializers = new Dictionary<Type, Bond.Serializer<FastBinaryWriter<OutputStream>>>();
			var deserializers = new Dictionary<Type, Bond.Deserializer<FastBinaryReader<InputStream>>>();
			foreach (var t in new[] { typeof(SmallObjects.Bond.Message), typeof(SmallObjects.Bond.Complex), typeof(SmallObjects.Bond.Post) })
			{
				serializers[t] = new Bond.Serializer<FastBinaryWriter<OutputStream>>(t);
				deserializers[t] = new Bond.Deserializer<FastBinaryReader<InputStream>>(t);
			}
			serialize = (obj, stream) =>
			{
				var output = new OutputStream(stream);
				var writer = new FastBinaryWriter<OutputStream>(output);
				serializers[obj.GetType()].Serialize(obj, writer);
				output.Flush();
			};
			deserialize = (stream, type) =>
			{
				var input = new InputStream(stream);
				var reader = new FastBinaryReader<InputStream>(input);
				return deserializers[type].Deserialize(reader);
			};
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
