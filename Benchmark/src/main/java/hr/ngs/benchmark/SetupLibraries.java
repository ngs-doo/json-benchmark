package hr.ngs.benchmark;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.parser.Feature;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.alibaba.fastjson.util.ThreadLocalCache;
import com.dslplatform.client.json.DslJsonSerialization;
import com.dslplatform.client.json.JsonObject;
import com.dslplatform.client.json.JsonWriter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.*;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.module.afterburner.AfterburnerModule;
import com.google.gson.*;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonParseException;
import com.google.gson.JsonSerializer;
import com.owlike.genson.Genson;
import com.owlike.genson.GensonBuilder;
import com.owlike.genson.ext.jodatime.JodaTimeBundle;
import de.javakaffee.kryoserializers.UUIDSerializer;
import de.javakaffee.kryoserializers.jodatime.JodaDateTimeSerializer;
import de.javakaffee.kryoserializers.jodatime.JodaLocalDateSerializer;
import flexjson.JSONDeserializer;
import flexjson.JSONSerializer;
import org.boon.json.JsonFactory;
import org.boon.json.JsonSerializerFactory;
import org.boon.json.serializers.CustomObjectSerializer;
import org.boon.json.serializers.JsonSerializerInternal;
import org.boon.primitive.CharBuf;
import org.joda.time.DateTime;
import org.joda.time.LocalDate;
import org.nustaq.serialization.FSTConfiguration;
import org.nustaq.serialization.FSTObjectInput;
import org.nustaq.serialization.FSTObjectOutput;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.lang.reflect.Type;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.util.*;

public class SetupLibraries {

	private final static Charset UTF8 = Charset.forName("UTF-8");

	static Serializer setupDslClient(final boolean minimal) throws IOException {
		final DslJsonSerialization json = new DslJsonSerialization(null);
		final JsonWriter sw = new JsonWriter();

		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				arg.serialize(sw, minimal);
				com.dslplatform.patterns.Bytes bytes = sw.toBytes();
				sw.reset();
				return new Bytes(bytes.content, bytes.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				return json.deserialize(manifest, input.content, input.length);
			}
		};
	}

	private static final SimpleModule jacksonModule =
			new SimpleModule()
					.addSerializer(LocalDate.class, new com.fasterxml.jackson.databind.JsonSerializer<LocalDate>() {
						@Override
						public void serialize(LocalDate value, JsonGenerator jg, SerializerProvider _) throws IOException {
							jg.writeString(value.toString());
						}
					})
					.addDeserializer(LocalDate.class, new com.fasterxml.jackson.databind.JsonDeserializer<LocalDate>() {
						@Override
						public LocalDate deserialize(JsonParser parser, DeserializationContext _) throws IOException {
							return LocalDate.parse(parser.getValueAsString());
						}
					})
					.addSerializer(DateTime.class, new com.fasterxml.jackson.databind.JsonSerializer<DateTime>() {
						@Override
						public void serialize(DateTime value, JsonGenerator jg, SerializerProvider _) throws IOException {
							jg.writeString(value.toString());
						}
					})
					.addDeserializer(DateTime.class, new com.fasterxml.jackson.databind.JsonDeserializer<DateTime>() {
						@Override
						public DateTime deserialize(JsonParser parser, DeserializationContext _) throws IOException {
							return DateTime.parse(parser.getValueAsString());
						}
					});

	static Serializer setupJackson() throws IOException {
		final ObjectMapper mapper = new ObjectMapper()
				.registerModule(jacksonModule)
				.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
				.configure(JsonParser.Feature.ALLOW_NON_NUMERIC_NUMBERS, true)
				.setSerializationInclusion(JsonInclude.Include.NON_NULL)
				.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				byte[] result = mapper.writeValueAsBytes(arg);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				return mapper.readValue(input.content, 0, input.length, manifest);
			}
		};
	}

	static Serializer setupJacksonAfterburner() throws IOException, NoSuchFieldException, IllegalAccessException {
		final ObjectMapper mapper = new ObjectMapper()
				.registerModule(jacksonModule)
				.registerModule(new AfterburnerModule())
				.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
				.configure(JsonParser.Feature.ALLOW_NON_NUMERIC_NUMBERS, true)
				.setSerializationInclusion(JsonInclude.Include.NON_NULL)
				.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				byte[] result = mapper.writeValueAsBytes(arg);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				return mapper.readValue(input.content, 0, input.length, manifest);
			}
		};
	}

	static class BoonLocalDateSerializer implements CustomObjectSerializer {
		@Override
		public Class type() {
			return LocalDate.class;
		}

		@Override
		public void serializeObject(JsonSerializerInternal jsonSerializerInternal, Object o, CharBuf charBuf) {
			charBuf.write(o.toString());
		}
	}

	static class BoonDateTimeSerializer implements CustomObjectSerializer {
		@Override
		public Class type() {
			return DateTime.class;
		}

		@Override
		public void serializeObject(JsonSerializerInternal jsonSerializerInternal, Object o, CharBuf charBuf) {
			charBuf.write(o.toString());
		}
	}

	//only custom writer, no custom parser!?
	static Serializer setupBoon() throws IOException {
		final org.boon.json.JsonSerializer serializer = new JsonSerializerFactory()
				.addTypeSerializer(LocalDate.class, new BoonLocalDateSerializer())
				.addTypeSerializer(DateTime.class, new BoonDateTimeSerializer())
				.create();
		final org.boon.json.ObjectMapper mapper = JsonFactory.create();
		final CharBuf cb = CharBuf.createCharBuf();
		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				serializer.serialize(cb, arg);
				cb.flush();
				String json = cb.toStringAndRecycle();
				byte[] result = json.getBytes(UTF8);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				return mapper.readValue(new String(input.content, 0, input.length, UTF8), manifest);
			}
		};
	}

	private static class GsonDateTimeTypeConverter implements JsonSerializer<DateTime>, JsonDeserializer<DateTime> {
		@Override
		public JsonElement serialize(DateTime src, Type srcType, JsonSerializationContext context) {
			return new JsonPrimitive(src.toString());
		}

		@Override
		public DateTime deserialize(JsonElement json, Type type, JsonDeserializationContext context) throws JsonParseException {
			return DateTime.parse(json.getAsString());
		}
	}

	private static class GsonLocalDateTypeConverter implements JsonSerializer<LocalDate>, JsonDeserializer<LocalDate> {
		@Override
		public JsonElement serialize(LocalDate src, Type srcType, JsonSerializationContext context) {
			return new JsonPrimitive(src.toString());
		}

		@Override
		public LocalDate deserialize(JsonElement json, Type type, JsonDeserializationContext context) throws JsonParseException {
			try {
				return new LocalDate(json.getAsString());
			} catch (IllegalArgumentException e) {
				// May be it came in formatted as a java.util.Date, so try that
				Date date = context.deserialize(json, Date.class);
				return new LocalDate(date);
			}
		}
	}

	static Serializer setupGson() throws IOException {
		GsonBuilder builder = new GsonBuilder();
		builder.registerTypeAdapter(DateTime.class, new GsonDateTimeTypeConverter());
		builder.registerTypeAdapter(LocalDate.class, new GsonLocalDateTypeConverter());
		final Gson gson = builder.create();
		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				StringWriter sw = new StringWriter();
				gson.toJson(arg, sw);
				sw.flush();
				byte[] result = sw.toString().getBytes(UTF8);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				return gson.fromJson(new String(input.content, 0, input.length, UTF8), manifest);
			}
		};
	}

	//TODO no custom handlers!?
	static Serializer setupAlibaba() throws IOException {
		final CharsetDecoder utf8 = ThreadLocalCache.getUTF8Decoder();
		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				byte[] result = JSON.toJSONBytes(arg, SerializerFeature.WriteEnumUsingToString, SerializerFeature.DisableCircularReferenceDetect);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				return JSON.parseObject(input.content, 0, input.length, utf8, manifest, Feature.DisableCircularReferenceDetect);
			}
		};
	}

	static Serializer setupGenson() throws IOException {
		final Genson genson = new GensonBuilder().withBundle(new JodaTimeBundle()).create();

		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				byte[] result = genson.serializeBytes(arg);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				return genson.deserialize(new ByteArrayInputStream(input.content, 0, input.length), manifest);
			}
		};
	}

	static Serializer setupFlexjson() throws IOException {
		final JSONSerializer serializer = new JSONSerializer();

		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				byte[] result = serializer.serialize(arg).getBytes(UTF8);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				JSONDeserializer<T> deserializer = new JSONDeserializer<T>();
				return deserializer.deserialize(new String(input.content, 0, input.length, UTF8), manifest);
			}
		};
	}

	static Serializer setupKryo() throws IOException {
		final com.esotericsoftware.kryo.Kryo kryo = new com.esotericsoftware.kryo.Kryo();
		kryo.setReferences(false);
		kryo.register(DateTime.class, new JodaDateTimeSerializer());
		kryo.register(LocalDate.class, new JodaLocalDateSerializer());
		kryo.register(UUID.class, new UUIDSerializer());
		final byte[] buffer = new byte[8192];
		final com.esotericsoftware.kryo.io.Output kryoOutput = new com.esotericsoftware.kryo.io.Output(buffer, -1);
		final com.esotericsoftware.kryo.io.Input kryoInput = new com.esotericsoftware.kryo.io.Input(buffer);

		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				kryoOutput.setBuffer(buffer, -1);
				kryo.writeObject(kryoOutput, arg);
				return new Bytes(kryoOutput.getBuffer(), kryoOutput.position());
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				kryoInput.setBuffer(input.content, 0, input.length);
				return (T) kryo.readObject(kryoInput, manifest);
			}
		};
	}

	static Serializer setupFst() throws IOException {
		final FSTConfiguration conf = FSTConfiguration.createDefaultConfiguration();
		conf.setShareReferences(false);
		final FSTObjectInput objectInput = new FSTObjectInput(conf);
		final FSTObjectOutput objectOutput = new FSTObjectOutput(conf);

		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				objectOutput.resetForReUse();
				objectOutput.writeObject(arg, arg.getClass());
				return new Bytes(objectOutput.getBuffer(), objectOutput.getWritten());
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				objectInput.resetForReuseUseArray(input.content, input.length);
				try {
					return (T) objectInput.readObject(manifest);
				} catch (Exception e) {
					throw new IOException(e);
				}
			}
		};
	}
}
