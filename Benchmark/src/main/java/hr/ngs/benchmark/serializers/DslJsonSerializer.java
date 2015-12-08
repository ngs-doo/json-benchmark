package hr.ngs.benchmark.serializers;

import com.dslplatform.json.DslJson;
import com.dslplatform.json.JsonObject;
import com.dslplatform.json.JsonWriter;
import hr.ngs.benchmark.Serializer;

import java.io.IOException;
import java.io.OutputStream;

public class DslJsonSerializer implements Serializer {
	final DslJson<Object> json = new DslJson<Object>();
	final JsonWriter sw = new JsonWriter();
	final boolean minimal;

	public DslJsonSerializer(boolean minimal) {
		this.minimal = minimal;
	}

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		arg.serialize(sw, minimal);
		sw.toStream(os);
		sw.reset();
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return json.deserialize(manifest, bytes, length);
	}
}
