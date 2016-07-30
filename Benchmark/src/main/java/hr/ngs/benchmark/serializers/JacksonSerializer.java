package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.module.afterburner.AfterburnerModule;
import hr.ngs.benchmark.Serializer;

import java.io.IOException;
import java.io.OutputStream;

public class JacksonSerializer implements Serializer {

	private final ObjectMapper mapper = new ObjectMapper()
			.registerModule(new JavaTimeModule())
			.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false)
			.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
			.configure(JsonParser.Feature.ALLOW_NON_NUMERIC_NUMBERS, true)
			.setSerializationInclusion(JsonInclude.Include.NON_NULL)
			.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);

	public JacksonSerializer(boolean withAfterburner) {
		if (withAfterburner) {
			mapper.registerModule(new AfterburnerModule());
		}
	}

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		mapper.writeValue(os, arg);
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return mapper.readValue(bytes, 0, length, manifest);
	}
}
