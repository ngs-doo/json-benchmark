package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import flexjson.JSONDeserializer;
import flexjson.JSONSerializer;
import flexjson.transformer.AbstractTransformer;
import hr.ngs.benchmark.Serializer;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public class FlexJsonSerializer implements Serializer {
	private static final AbstractTransformer IDENTITY = new AbstractTransformer() {
		@Override
		public void transform(Object o) {
			getContext().writeQuoted(o.toString());
		}
	};
	private final JSONSerializer serializer =
			new JSONSerializer()
					.transform(IDENTITY, UUID.class)
					.transform(IDENTITY, LocalDate.class)
					.transform(IDENTITY, OffsetDateTime.class);
	private final JSONDeserializer<Object> deserializer =
			new JSONDeserializer<>()
					.use(UUID.class, (objectBinder, o, type, aClass) -> UUID.fromString((String) o))
					.use(LocalDate.class, (objectBinder, o, type, aClass) -> LocalDate.parse((String) o))
					.use(OffsetDateTime.class, (objectBinder, o, type, aClass) -> OffsetDateTime.parse((String) o));
	private final static Charset UTF8 = Charset.forName("UTF-8");

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		os.write(serializer.serialize(arg).getBytes(UTF8));
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return (T) deserializer.deserialize(new String(bytes, 0, length, UTF8), manifest);
	}
}
