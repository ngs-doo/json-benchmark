package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import com.owlike.genson.Genson;
import com.owlike.genson.GensonBuilder;
import hr.ngs.benchmark.Serializer;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;

public class GensonSerializer implements Serializer {
	private final Genson genson = new GensonBuilder()
			.useDateAsTimestamp(false)
			.create();
	private final static Charset UTF8 = Charset.forName("UTF-8");

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		genson.serialize(arg, os);
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return genson.deserialize(new String(bytes, 0, length, UTF8), manifest);
	}
}
