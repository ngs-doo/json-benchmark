package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import flexjson.JSONDeserializer;
import flexjson.JSONSerializer;
import flexjson.ObjectBinder;
import flexjson.ObjectFactory;
import flexjson.transformer.AbstractTransformer;
import flexjson.transformer.BasicDateTransformer;
import flexjson.transformer.ValueTransformer;
import hr.ngs.benchmark.Serializer;
import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Type;
import java.nio.charset.Charset;
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
					.transform(IDENTITY, DateTime.class);
	private final JSONDeserializer<Object> deserializer =
			new JSONDeserializer<Object>()
					.use(UUID.class, new ObjectFactory() {
						@Override
						public Object instantiate(ObjectBinder objectBinder, Object o, Type type, Class aClass) {
							return UUID.fromString((String) o);
						}
					});
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
