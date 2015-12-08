package hr.ngs.benchmark.serializers;

import com.google.gson.*;
import hr.ngs.benchmark.Serializer;
import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.reflect.Type;
import java.nio.charset.Charset;
import java.util.Date;

public class GsonSerializer implements Serializer {
	private final static Charset UTF8 = Charset.forName("UTF-8");

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

	final Gson gson;

	public GsonSerializer() {
		GsonBuilder builder = new GsonBuilder();
		builder.registerTypeAdapter(DateTime.class, new GsonDateTimeTypeConverter());
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
