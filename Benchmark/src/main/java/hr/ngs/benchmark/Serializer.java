package hr.ngs.benchmark;

import java.io.IOException;
import java.io.OutputStream;

public interface Serializer {
	void serialize(com.dslplatform.json.JsonObject arg, OutputStream stream) throws IOException;

	<T> T deserialize(Class<T> manifest, byte[] bytes, int len) throws IOException;
}