package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import hr.ngs.benchmark.Serializer;
import org.nustaq.serialization.FSTConfiguration;
import org.nustaq.serialization.FSTObjectInput;
import org.nustaq.serialization.FSTObjectOutput;

import java.io.IOException;
import java.io.OutputStream;

public class FstSerializer implements Serializer {
	private final FSTConfiguration conf;
	private final FSTObjectInput objectInput;
	private final FSTObjectOutput objectOutput;

	public FstSerializer() {
		conf = FSTConfiguration.createDefaultConfiguration();
		conf.setShareReferences(false);
		objectInput = new FSTObjectInput(conf);
		objectOutput = new FSTObjectOutput(conf);
	}

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		objectOutput.resetForReUse();
		objectOutput.writeObject(arg, arg.getClass());
		os.write(objectOutput.getBuffer(), 0, objectOutput.getWritten());
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		objectInput.resetForReuseUseArray(bytes, length);
		try {
			return (T) objectInput.readObject(manifest);
		} catch (Exception e) {
			throw new IOException(e);
		}
	}
}
