package hr.ngs.benchmark;

import java.io.IOException;

interface Serializer {
	Bytes serialize(com.dslplatform.client.json.JsonObject arg) throws IOException;
	<T> T deserialize(Class<T> manifest, Bytes input) throws IOException;
}