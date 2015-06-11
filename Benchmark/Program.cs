using Bond.IO.Unsafe;
using Bond.Protocols;
using Revenj.Extensibility;
using Revenj.Serialization;
using Revenj.Utility;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters;

namespace JsonBenchmark
{
	class Program
	{
		enum BenchTarget
		{
			RevenjJsonFull, RevenjJsonMinimal, ProtoBuf, NewtonsoftJson,
			Jil, fastJSON, ServiceStack, BondJson, BondBinary, NetJSON
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
			//args = new[] { "BondJson", "Small", "Both", "100" };
			//args = new[] { "BakedInMinimal", "Small", "Both", "10000000" };
			//args = new[] { "RevenjJsonMinimal", "Large", "Check", "100" };
			//args = new[] { "ServiceStack", "Large", "Check", "100" };
			//args = new[] { "fastJSON", "Small", "Serialization", "1000000" };
			//args = new[] { "NewtonsoftJson", "Small", "Serialization", "10000000" };
			//args = new[] { "NetJSON", "Small", "Serialization", "1000000" };
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
				case BenchTarget.RevenjJsonFull:
					SetupRevenj(out serialize, out deserialize, "application/json");
					break;
				default:
					SetupRevenj(out serialize, out deserialize, "application/json;minimal");
					break;
			}
			var ms = new ChunkedMemoryStream();
			switch (size)
			{
				case BenchSize.Small:
					try
					{
						if (target == BenchTarget.BondBinary || target == BenchTarget.BondJson)
						{
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Message.FactoryBond);
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Complex.FactoryBond);
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Post.FactoryBond);
						}
						else if (target == BenchTarget.RevenjJsonFull || target == BenchTarget.RevenjJsonMinimal)
						{
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Message.FactoryDsl);
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Complex.FactoryDsl);
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Post.FactoryDsl);
						}
						else
						{
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Message.FactoryPoco);
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Complex.FactoryPoco);
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Small.Post.FactoryPoco);
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
						if (target == BenchTarget.RevenjJsonFull || target == BenchTarget.RevenjJsonMinimal)
						{
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Standard.DeletePost.FactoryDsl);
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Standard.Post.FactoryDsl);
						}
						else
						{
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Standard.DeletePost.FactoryPoco);
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Standard.Post.FactoryPoco);
						}
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
						if (target == BenchTarget.RevenjJsonFull || target == BenchTarget.RevenjJsonMinimal)
						{
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Large.Book.FactoryDsl);
						}
						else
						{
							RunLoop(repeat, serialize, deserialize, type, ms, Models.Large.Book.FactoryPoco);
						}
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
			var isEquatable = typeof(T).GetInterfaces().Any(it => it == typeof(IEquatable<T>));
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
					if (type == BenchType.Check && (isEquatable ? !((IEquatable<T>)message).Equals(deser) : !message.Equals(deser)))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
		}

		static void SetupRevenj(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize,
			string contentType)
		{
			var binder = new GenericDeserializationBinder(new Lazy<ITypeResolver>(() => null));
			IWireSerialization serialization = new WireSerialization(binder);
			serialize = (obj, stream) => serialization.Serialize(obj, contentType, stream);
			deserialize = (stream, type) => serialization.Deserialize(stream, type, contentType, default(StreamingContext));
		}

		static void SetupNewtonsoftJson(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize)
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

		static void SetupJil(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			serialize = (obj, stream) =>
			{
				var sw = stream.GetWriter();
				Jil.JSON.Serialize(obj, sw);
				sw.Flush();
			};
			deserialize = (stream, type) => Jil.JSON.Deserialize(stream.GetReader(), type);
		}

		static void SetupBondJson(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			var serializers = new Dictionary<Type, Bond.Serializer<SimpleJsonWriter>>();
			var deserializers = new Dictionary<Type, Bond.Deserializer<SimpleJsonReader>>();
			serialize = (obj, stream) =>
			{
				var jsonWriter = new SimpleJsonWriter(stream);
				var type = obj.GetType();
				Bond.Serializer<SimpleJsonWriter> serializer;
				if (!serializers.TryGetValue(type, out serializer))
					serializers[type] = serializer = new Bond.Serializer<SimpleJsonWriter>(type);
				serializer.Serialize(obj, jsonWriter);
				jsonWriter.Flush();
			};
			deserialize = (stream, type) =>
			{
				var reader = new SimpleJsonReader(stream);
				Bond.Deserializer<SimpleJsonReader> deserializer;
				if (!deserializers.TryGetValue(type, out deserializer))
					deserializers[type] = deserializer = new Bond.Deserializer<SimpleJsonReader>(type);
				return deserializer.Deserialize(reader);
			};
		}

		static void SetupBondBinary(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			var serializers = new Dictionary<Type, Bond.Serializer<FastBinaryWriter<OutputStream>>>();
			var deserializers = new Dictionary<Type, Bond.Deserializer<FastBinaryReader<InputStream>>>();
			serialize = (obj, stream) =>
			{
				var output = new OutputStream(stream, 512);
				var writer = new FastBinaryWriter<OutputStream>(output);
				Bond.Serializer<FastBinaryWriter<OutputStream>> serializer;
				var type = obj.GetType();
				if (!serializers.TryGetValue(type, out serializer))
					serializers[type] = serializer = new Bond.Serializer<FastBinaryWriter<OutputStream>>(type);
				serializer.Serialize(obj, writer);
				output.Flush();
			};
			deserialize = (stream, type) =>
			{
				var input = new InputStream(stream, 512);
				var reader = new FastBinaryReader<InputStream>(input);
				Bond.Deserializer<FastBinaryReader<InputStream>> deserializer;
				if (!deserializers.TryGetValue(type, out deserializer))
					deserializers[type] = deserializer = new Bond.Deserializer<FastBinaryReader<InputStream>>(type);
				return deserializer.Deserialize(reader);
			};
		}

		static void SetupFastJson(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			serialize = (obj, stream) =>
			{
				var sw = stream.GetWriter();
				sw.Write(fastJSON.JSON.ToJSON(obj));
				sw.Flush();
			};
			//TODO: forced to string conversion ;(
			deserialize = (stream, type) => fastJSON.JSON.ToObject(stream.GetReader().ReadToEnd(), type);
		}

		static void SetupServiceStack(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			serialize = (obj, stream) => ServiceStack.Text.JsonSerializer.SerializeToStream(obj, stream);
			deserialize = (stream, type) => ServiceStack.Text.JsonSerializer.DeserializeFromStream(type, stream);
		}

		static void SetupNetJSON(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			var dict = new Dictionary<Type, Func<TextReader, object>>();
			//TODO: not really nice... but let's avoid to string conversion
			dict[typeof(Models.Small.Message)] = reader => NetJSON.NetJSON.Deserialize<Models.Small.Message>(reader);
			dict[typeof(Models.Small.Complex)] = reader => NetJSON.NetJSON.Deserialize<Models.Small.Complex>(reader);
			dict[typeof(Models.Small.Post)] = reader => NetJSON.NetJSON.Deserialize<Models.Small.Post>(reader);
			dict[typeof(Models.Standard.DeletePost)] = reader => NetJSON.NetJSON.Deserialize<Models.Standard.DeletePost>(reader);
			dict[typeof(Models.Standard.Post)] = reader => NetJSON.NetJSON.Deserialize<Models.Standard.Post>(reader);
			dict[typeof(Models.Large.Book)] = reader => NetJSON.NetJSON.Deserialize<Models.Large.Book>(reader);
			serialize = (obj, stream) =>
			{
				var writer = stream.GetWriter();
				NetJSON.NetJSON.Serialize(obj, writer);
				writer.Flush();
			};
			deserialize = (stream, type) => dict[type](stream.GetReader());
		}
	}
}
