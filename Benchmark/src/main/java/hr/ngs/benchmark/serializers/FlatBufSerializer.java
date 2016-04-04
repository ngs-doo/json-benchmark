package hr.ngs.benchmark.serializers;

import com.dslplatform.json.JsonObject;
import com.google.flatbuffers.FlatBufferBuilder;
import hr.ngs.benchmark.Serializer;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.nio.ByteBuffer;
import java.util.UUID;

public class FlatBufSerializer implements Serializer {
	private final FlatBufferBuilder fbb = new FlatBufferBuilder();

	@Override
	public void serialize(JsonObject arg, OutputStream os) throws IOException {
		if (arg instanceof hr.ngs.benchmark.SmallObjects.Message) {
			hr.ngs.benchmark.SmallObjects.Message msg = (hr.ngs.benchmark.SmallObjects.Message) arg;
			int offset = FlatBuf.SmallObjects.Message.createMessage(
					fbb,
					fbb.createString(msg.getMessage()),
					msg.getVersion());
			FlatBuf.SmallObjects.Message.finishMessageBuffer(fbb, offset);
		} else if (arg instanceof hr.ngs.benchmark.SmallObjects.Complex) {
			hr.ngs.benchmark.SmallObjects.Complex c = (hr.ngs.benchmark.SmallObjects.Complex) arg;
			int offset = FlatBuf.SmallObjects.Complex.createComplex(
					fbb,
					fbb.createString(c.getX().toString()),
					c.getY(),
					c.getZ());
			FlatBuf.SmallObjects.Complex.finishComplexBuffer(fbb, offset);
		} else if (arg instanceof hr.ngs.benchmark.SmallObjects.Post) {
			hr.ngs.benchmark.SmallObjects.Post post = (hr.ngs.benchmark.SmallObjects.Post) arg;
			int offset = FlatBuf.SmallObjects.Post.createPost(
					fbb,
					fbb.createString(post.getID().toString()),
					fbb.createString(post.getTitle()),
					post.getActive(),
					post.getCreated().toDate().getTime());
			FlatBuf.SmallObjects.Post.finishPostBuffer(fbb, offset);
		} else {
			throw new IOException("Unknown target");
		}
		ByteBuffer bb = fbb.dataBuffer();
		os.write(bb.array(), bb.position(), bb.capacity() - bb.position());
		//TODO: no reset :D
		fbb.init(fbb.dataBuffer());
	}

	@Override
	public <T> T deserialize(Class<T> manifest, byte[] bytes, int length) throws IOException {
		ByteBuffer bb = ByteBuffer.wrap(bytes, 0, length);
		if (manifest.equals(hr.ngs.benchmark.SmallObjects.Message.class)) {
			FlatBuf.SmallObjects.Message message = FlatBuf.SmallObjects.Message.getRootAsMessage(bb);
			return (T) new hr.ngs.benchmark.SmallObjects.Message()
					.setMessage(message.message())
					.setVersion(message.version());
		} else if (manifest.equals(hr.ngs.benchmark.SmallObjects.Complex.class)) {
			FlatBuf.SmallObjects.Complex c = FlatBuf.SmallObjects.Complex.getRootAsComplex(bb);
			return (T) new hr.ngs.benchmark.SmallObjects.Complex()
					.setX(new BigDecimal(c.x()))
					.setY(c.y())
					.setZ(c.z());
		} else if (manifest.equals(hr.ngs.benchmark.SmallObjects.Post.class)) {
			FlatBuf.SmallObjects.Post post = FlatBuf.SmallObjects.Post.getRootAsPost(bb);
			return (T) new hr.ngs.benchmark.SmallObjects.Post()
					.setID(UUID.fromString(post.ID()))
					.setTitle(post.title())
					.setActive(post.active())
					.setCreated(new LocalDate(post.created()));
		}
		return null;
	}
}
