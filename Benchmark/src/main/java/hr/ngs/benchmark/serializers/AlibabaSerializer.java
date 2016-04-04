package hr.ngs.benchmark.serializers;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.parser.Feature;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.alibaba.fastjson.util.ThreadLocalCache;
import com.dslplatform.json.JsonObject;
import hr.ngs.benchmark.Serializer;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;

public class AlibabaSerializer implements Serializer {
	private final static Charset UTF8 = Charset.forName("UTF-8");

	private final CharsetDecoder utf8 = ThreadLocalCache.getUTF8Decoder();

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		OutputStreamWriter osw = new OutputStreamWriter(os, UTF8);
		JSON.writeJSONStringTo(arg, osw, SerializerFeature.WriteEnumUsingToString, SerializerFeature.DisableCircularReferenceDetect);
		osw.flush();
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return JSON.parseObject(bytes, 0, length, utf8, manifest, Feature.DisableCircularReferenceDetect);
	}
}
