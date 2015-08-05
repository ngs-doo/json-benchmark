// automatically generated, do not modify

package FlatBuf.SmallObjects;

import com.google.flatbuffers.FlatBufferBuilder;
import com.google.flatbuffers.Table;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class Message extends Table {
  public static FlatBuf.SmallObjects.Message getRootAsMessage(ByteBuffer _bb) { return getRootAsMessage(_bb, new FlatBuf.SmallObjects.Message()); }
  public static FlatBuf.SmallObjects.Message getRootAsMessage(ByteBuffer _bb, FlatBuf.SmallObjects.Message obj) { _bb.order(ByteOrder.LITTLE_ENDIAN); return (obj.__init(_bb.getInt(_bb.position()) + _bb.position(), _bb)); }
  public FlatBuf.SmallObjects.Message __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public String message() { int o = __offset(4); return o != 0 ? __string(o + bb_pos) : null; }
  public ByteBuffer messageAsByteBuffer() { return __vector_as_bytebuffer(4, 1); }
  public int version() { int o = __offset(6); return o != 0 ? bb.getInt(o + bb_pos) : 0; }

  public static int createMessage(FlatBufferBuilder builder,
      int message,
      int version) {
    builder.startObject(2);
    FlatBuf.SmallObjects.Message.addVersion(builder, version);
    FlatBuf.SmallObjects.Message.addMessage(builder, message);
    return FlatBuf.SmallObjects.Message.endMessage(builder);
  }

  public static void startMessage(FlatBufferBuilder builder) { builder.startObject(2); }
  public static void addMessage(FlatBufferBuilder builder, int messageOffset) { builder.addOffset(0, messageOffset, 0); }
  public static void addVersion(FlatBufferBuilder builder, int version) { builder.addInt(1, version, 0); }
  public static int endMessage(FlatBufferBuilder builder) {
    int o = builder.endObject();
    return o;
  }
  public static void finishMessageBuffer(FlatBufferBuilder builder, int offset) { builder.finish(offset); }
};

