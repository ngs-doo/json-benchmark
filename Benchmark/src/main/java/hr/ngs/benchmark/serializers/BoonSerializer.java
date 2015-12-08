package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import hr.ngs.benchmark.Serializer;
import org.boon.json.JsonFactory;
import org.boon.json.JsonSerializerFactory;
import org.boon.json.serializers.CustomObjectSerializer;
import org.boon.json.serializers.JsonSerializerInternal;
import org.boon.primitive.CharBuf;
import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;

public class BoonSerializer implements Serializer {
	private final static Charset UTF8 = Charset.forName("UTF-8");

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

	final org.boon.json.JsonSerializer serializer = new JsonSerializerFactory()
			.addTypeSerializer(LocalDate.class, new BoonLocalDateSerializer())
			.addTypeSerializer(DateTime.class, new BoonDateTimeSerializer())
			.create();
	final org.boon.json.ObjectMapper mapper = JsonFactory.create();
	final CharBuf cb = CharBuf.createCharBuf();

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
