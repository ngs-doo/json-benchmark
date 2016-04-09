package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.module.afterburner.AfterburnerModule;
import hr.ngs.benchmark.Serializer;
import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.io.OutputStream;

public class JacksonSerializer implements Serializer {
	private static final SimpleModule jacksonModule =
			new SimpleModule()
					.addSerializer(LocalDate.class, new com.fasterxml.jackson.databind.JsonSerializer<LocalDate>() {
						@Override
						public void serialize(LocalDate value, JsonGenerator jg, SerializerProvider p) throws IOException {
							jg.writeString(value.toString());
						}
					})
					.addDeserializer(LocalDate.class, new com.fasterxml.jackson.databind.JsonDeserializer<LocalDate>() {
						@Override
						public LocalDate deserialize(JsonParser parser, DeserializationContext p) throws IOException {
							return LocalDate.parse(parser.getValueAsString());
						}
					})
					.addSerializer(DateTime.class, new com.fasterxml.jackson.databind.JsonSerializer<DateTime>() {
						@Override
						public void serialize(DateTime value, JsonGenerator jg, SerializerProvider p) throws IOException {
							jg.writeString(value.toString());
						}
					})
					.addDeserializer(DateTime.class, new com.fasterxml.jackson.databind.JsonDeserializer<DateTime>() {
						@Override
						public DateTime deserialize(JsonParser parser, DeserializationContext p) throws IOException {
							return DateTime.parse(parser.getValueAsString());
						}
					});

	private final ObjectMapper mapper = new ObjectMapper()
			.registerModule(jacksonModule)
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
