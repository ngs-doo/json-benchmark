package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import com.owlike.genson.Genson;
import com.owlike.genson.GensonBuilder;
import com.owlike.genson.ext.jodatime.JodaTimeBundle;
import hr.ngs.benchmark.Serializer;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.OutputStream;

public class GensonSerializer implements Serializer {
	final Genson genson = new GensonBuilder().withBundle(new JodaTimeBundle()).create();

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		genson.serialize(arg, os);
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return genson.deserialize(new ByteArrayInputStream(bytes, 0, length), manifest);
	}
}
