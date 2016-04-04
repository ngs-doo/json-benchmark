package hr.ngs.benchmark.serializers;

import de.javakaffee.kryoserializers.UUIDSerializer;
import de.javakaffee.kryoserializers.jodatime.JodaDateTimeSerializer;
import de.javakaffee.kryoserializers.jodatime.JodaLocalDateSerializer;

import com.dslplatform.json.JsonObject;
import hr.ngs.benchmark.Serializer;
import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.io.OutputStream;
import java.util.UUID;

public class KryoSerializer implements Serializer {
	private final com.esotericsoftware.kryo.Kryo kryo = new com.esotericsoftware.kryo.Kryo();
	private final byte[] buffer = new byte[8192];
	private final com.esotericsoftware.kryo.io.Output kryoOutput = new com.esotericsoftware.kryo.io.Output(buffer, -1);
	private final com.esotericsoftware.kryo.io.Input kryoInput = new com.esotericsoftware.kryo.io.Input(buffer);

	public KryoSerializer() {
		kryo.setReferences(false);
		kryo.register(DateTime.class, new JodaDateTimeSerializer());
		kryo.register(LocalDate.class, new JodaLocalDateSerializer());
		kryo.register(UUID.class, new UUIDSerializer());
	}

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		kryoOutput.setBuffer(buffer, -1);
		kryo.writeObject(kryoOutput, arg);
		os.write(kryoOutput.getBuffer(), 0, kryoOutput.position());
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		kryoInput.setBuffer(bytes, 0, length);
		return (T) kryo.readObject(kryoInput, manifest);
	}
}
