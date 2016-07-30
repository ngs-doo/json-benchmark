package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import hr.ngs.benchmark.Serializer;
import io.advantageous.boon.json.*;
import io.advantageous.boon.json.serializers.CustomObjectSerializer;
import io.advantageous.boon.json.serializers.JsonSerializerInternal;
import io.advantageous.boon.primitive.CharBuf;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public class BoonSerializer implements Serializer {
	private final static Charset UTF8 = Charset.forName("UTF-8");

	private static class BoonLocalDateSerializer implements CustomObjectSerializer {
		@Override
		public Class type() {
			return LocalDate.class;
		}

		@Override
		public void serializeObject(JsonSerializerInternal jsonSerializerInternal, Object o, CharBuf charBuf) {
			charBuf.write(o.toString());
		}
	}

	private static class BoonDateTimeSerializer implements CustomObjectSerializer {
		@Override
		public Class type() {
			return OffsetDateTime.class;
		}

		@Override
		public void serializeObject(JsonSerializerInternal jsonSerializerInternal, Object o, CharBuf charBuf) {
			charBuf.write(o.toString());
		}
	}

	private final JsonSerializer serializer = new JsonSerializerFactory()
			.addTypeSerializer(LocalDate.class, new BoonLocalDateSerializer())
			.addTypeSerializer(OffsetDateTime.class, new BoonDateTimeSerializer())
			.create();
	private final ObjectMapper mapper = JsonFactory.create();
	private final CharBuf cb = CharBuf.createCharBuf();

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		serializer.serialize(cb, arg);
		cb.flush();
		String json = cb.toStringAndRecycle();
		OutputStreamWriter osw = new OutputStreamWriter(os, UTF8);
		osw.write(json);
		osw.flush();
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return mapper.readValue(new String(bytes, 0, length, UTF8), manifest);
	}
}
