package hr.ngs.benchmark.serializers;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.parser.*;
import com.alibaba.fastjson.serializer.*;
import com.dslplatform.json.JsonObject;
import hr.ngs.benchmark.Serializer;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.Charset;

public class AlibabaSerializer implements Serializer {
	private final static Charset UTF8 = Charset.forName("UTF-8");

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		JSON.writeJSONString(os, UTF8, arg, SerializerFeature.WriteEnumUsingToString, SerializerFeature.DisableCircularReferenceDetect, SerializerFeature.UseISO8601DateFormat);
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		return JSON.parseObject(bytes, 0, length, UTF8, manifest, Feature.DisableCircularReferenceDetect, Feature.AllowISO8601DateFormat);
	}
}
