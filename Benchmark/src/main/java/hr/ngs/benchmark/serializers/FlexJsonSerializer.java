package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import flexjson.JSONDeserializer;
import flexjson.JSONSerializer;
import hr.ngs.benchmark.Serializer;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;

public class FlexJsonSerializer implements Serializer {
	final JSONSerializer serializer = new JSONSerializer();
	private final static Charset UTF8 = Charset.forName("UTF-8");

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		OutputStreamWriter osw = new OutputStreamWriter(os, UTF8);
		serializer.serialize(osw);
		osw.flush();
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		JSONDeserializer<T> deserializer = new JSONDeserializer<T>();
		return deserializer.deserialize(new String(bytes, 0, length, UTF8), manifest);
	}
}
