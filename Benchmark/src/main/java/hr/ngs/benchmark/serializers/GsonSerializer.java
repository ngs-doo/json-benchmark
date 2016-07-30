package hr.ngs.benchmark.serializers;

import com.google.gson.*;
import hr.ngs.benchmark.Serializer;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.reflect.Type;
import java.nio.charset.Charset;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public class GsonSerializer implements Serializer {
	private final static Charset UTF8 = Charset.forName("UTF-8");

	private static class GsonDateTimeTypeConverter implements JsonSerializer<OffsetDateTime>, JsonDeserializer<OffsetDateTime> {
		@Override
		public JsonElement serialize(OffsetDateTime src, Type srcType, JsonSerializationContext context) {
			return new JsonPrimitive(src.toString());
		}

		@Override
		public OffsetDateTime deserialize(JsonElement json, Type type, JsonDeserializationContext context) throws JsonParseException {
			return OffsetDateTime.parse(json.getAsString());
		}
	}

	private static class GsonLocalDateTypeConverter implements JsonSerializer<LocalDate>, JsonDeserializer<LocalDate> {
		@Override
		public JsonElement serialize(LocalDate src, Type srcType, JsonSerializationContext context) {
			return new JsonPrimitive(src.toString());
		}

		@Override
		public LocalDate deserialize(JsonElement json, Type type, JsonDeserializationContext context) throws JsonParseException {
			return LocalDate.parse(json.getAsString());
		}
	}

	private final Gson gson;

	public GsonSerializer() {
		GsonBuilder builder = new GsonBuilder();
		builder.registerTypeAdapter(OffsetDateTime.class, new GsonDateTimeTypeConverter());
		builder.registerTypeAdapter(LocalDate.class, new GsonLocalDateTypeConverter());
		gson = builder.create();
	}

	@Override
	public void serialize(com.dslplatform.json.JsonObject arg, OutputStream os) throws IOException {
		OutputStreamWriter osw = new OutputStreamWriter(os, UTF8);
		gson.toJson(arg, osw);
		osw.flush();
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return gson.fromJson(new String(bytes, 0, length, UTF8), manifest);
	}
}
