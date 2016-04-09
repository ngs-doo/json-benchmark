package hr.ngs.benchmark.serializers;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.parser.*;
import com.alibaba.fastjson.parser.deserializer.ObjectDeserializer;
import com.alibaba.fastjson.serializer.*;
import com.alibaba.fastjson.util.ThreadLocalCache;
import com.dslplatform.json.JsonObject;
import hr.ngs.benchmark.Serializer;
import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.reflect.Type;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;

public class AlibabaSerializer implements Serializer {
	private final static Charset UTF8 = Charset.forName("UTF-8");

	private final CharsetDecoder utf8 = ThreadLocalCache.getUTF8Decoder();

	static class LocalDateCodec implements ObjectSerializer, ObjectDeserializer {
		@Override
		public <T> T deserialze(DefaultJSONParser parser, Type type, Object o) {
			JSONLexer lexer = parser.getLexer();
			if (lexer.token() == JSONToken.LITERAL_STRING) {
				String text = lexer.stringVal();
				lexer.nextToken();
				return (T) LocalDate.parse(text);
			}
			return null;
		}

		@Override
		public int getFastMatchToken() {
			return JSONToken.LITERAL_STRING;
		}

		@Override
		public void write(JSONSerializer serializer, Object object, Object fieldName, Type type, int i) throws IOException {
			SerializeWriter out = serializer.getWriter();
			if (object == null) {
				out.writeNull();
				return;
			}
			out.writeString(object.toString());
		}
	}

	static class DateTimeCodec implements ObjectSerializer, ObjectDeserializer {
		@Override
		public <T> T deserialze(DefaultJSONParser parser, Type type, Object o) {
			JSONLexer lexer = parser.getLexer();
			if (lexer.token() == JSONToken.LITERAL_STRING) {
				String text = lexer.stringVal();
				lexer.nextToken();
				return (T) DateTime.parse(text);
			}
			return null;
		}

		@Override
		public int getFastMatchToken() {
			return JSONToken.LITERAL_STRING;
		}

		@Override
		public void write(JSONSerializer serializer, Object object, Object fieldName, Type type, int i) throws IOException {
			SerializeWriter out = serializer.getWriter();
			if (object == null) {
				out.writeNull();
				return;
			}
			out.writeString(object.toString());
		}
	}

	public AlibabaSerializer() {
		ParserConfig.getGlobalInstance().putDeserializer(LocalDate.class, new LocalDateCodec());
		SerializeConfig.getGlobalInstance().put(LocalDate.class, new LocalDateCodec());
		ParserConfig.getGlobalInstance().putDeserializer(DateTime.class, new DateTimeCodec());
		SerializeConfig.getGlobalInstance().put(DateTime.class, new DateTimeCodec());
	}

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		OutputStreamWriter osw = new OutputStreamWriter(os, UTF8);
		JSON.writeJSONStringTo(arg, osw, SerializerFeature.WriteEnumUsingToString, SerializerFeature.DisableCircularReferenceDetect, SerializerFeature.UseISO8601DateFormat);
		osw.flush();
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return JSON.parseObject(bytes, 0, length, utf8, manifest, Feature.DisableCircularReferenceDetect, Feature.AllowISO8601DateFormat);
	}
}
