using Bond.IO.Unsafe;
using Bond.Protocols;
using Revenj.Extensibility;
using Revenj.Serialization;
using Revenj.Utility;
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters;

namespace JsonBenchmark
{
	internal static class LibrarySetup
	{

		public static void SetupRevenj(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize,
			string contentType)
		{
			var binder = new GenericDeserializationBinder(new Lazy<ITypeResolver>(() => null));
			IWireSerialization serialization = new WireSerialization(binder);
			serialize = (obj, stream) => serialization.Serialize(obj, contentType, stream);
			deserialize = (stream, type) => serialization.Deserialize(stream, type, contentType, default(StreamingContext));
		}

		public static void SetupNewtonsoftJson(
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

		public static void SetupJil(
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

		public static void SetupBondJson(
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

		public static void SetupBondBinary(
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

		public static void SetupFastJson(
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

		public static void SetupServiceStack(
			out Action<object, ChunkedMemoryStream> serialize,
			out Func<ChunkedMemoryStream, Type, object> deserialize)
		{
			serialize = (obj, stream) => ServiceStack.Text.JsonSerializer.SerializeToStream(obj, obj.GetType(), stream);
			deserialize = (stream, type) => ServiceStack.Text.JsonSerializer.DeserializeFromStream(type, stream);
		}

		public static void SetupNetJSON(
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
