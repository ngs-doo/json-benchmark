// automatically generated, do not modify

package FlatBuf.SmallObjects;

import java.nio.*;
import java.lang.*;
import java.util.*;
import com.google.flatbuffers.*;

public class Complex extends Table {
  public static Complex getRootAsComplex(ByteBuffer _bb) { return getRootAsComplex(_bb, new Complex()); }
  public static Complex getRootAsComplex(ByteBuffer _bb, Complex obj) { _bb.order(ByteOrder.LITTLE_ENDIAN); return (obj.__init(_bb.getInt(_bb.position()) + _bb.position(), _bb)); }
  public Complex __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public String x() { int o = __offset(4); return o != 0 ? __string(o + bb_pos) : null; }
  public ByteBuffer xAsByteBuffer() { return __vector_as_bytebuffer(4, 1); }
  public float y() { int o = __offset(6); return o != 0 ? bb.getFloat(o + bb_pos) : 0; }
  public long z() { int o = __offset(8); return o != 0 ? bb.getLong(o + bb_pos) : 0; }

  public static int createComplex(FlatBufferBuilder builder,
      int x,
      float y,
      long z) {
    builder.startObject(3);
    Complex.addZ(builder, z);
    Complex.addY(builder, y);
    Complex.addX(builder, x);
    return Complex.endComplex(builder);
  }

  public static void startComplex(FlatBufferBuilder builder) { builder.startObject(3); }
  public static void addX(FlatBufferBuilder builder, int xOffset) { builder.addOffset(0, xOffset, 0); }
  public static void addY(FlatBufferBuilder builder, float y) { builder.addFloat(1, y, 0); }
  public static void addZ(FlatBufferBuilder builder, long z) { builder.addLong(2, z, 0); }
  public static int endComplex(FlatBufferBuilder builder) {
    int o = builder.endObject();
    return o;
  }
  public static void finishComplexBuffer(FlatBufferBuilder builder, int offset) { builder.finish(offset); }
};

