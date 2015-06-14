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
import org.boon.json.JsonFactory;
import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.io.StringWriter;
import java.lang.reflect.Type;
import java.nio.charset.CharsetDecoder;
import java.util.*;

public class SetupLibraries {

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

	static Serializer setupBoon() throws IOException {
		final org.boon.json.ObjectMapper mapper =  JsonFactory.create();
		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				byte[] result = mapper.writeValueAsBytes(arg);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				if (input.length == input.content.length) {
					return mapper.readValue(input.content, manifest);
				} else {
					return mapper.readValue(Arrays.copyOf(input.content, input.length), manifest);
				}
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
				byte[] result = sw.toString().getBytes("UTF-8");
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				return gson.fromJson(new String(input.content, 0, input.length, "UTF-8"), manifest);
			}
		};
	}

	static Serializer setupAlibaba() throws IOException {
		return new Serializer() {
			@Override
			public Bytes serialize(JsonObject arg) throws IOException {
				byte[] result = JSON.toJSONBytes(arg, SerializerFeature.WriteEnumUsingToString, SerializerFeature.DisableCircularReferenceDetect);
				return new Bytes(result, result.length);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, Bytes input) throws IOException {
				CharsetDecoder utf8 = ThreadLocalCache.getUTF8Decoder();
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
				if (input.length == input.content.length) {
					return genson.deserialize(input.content, manifest);
				} else {
					return genson.deserialize(Arrays.copyOf(input.content, input.length), manifest);
				}
			}
		};
	}
}
