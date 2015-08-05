// automatically generated, do not modify

package FlatBuf.SmallObjects;

import java.nio.*;
import java.lang.*;
import java.util.*;
import com.google.flatbuffers.*;

public class Post extends Table {
  public static Post getRootAsPost(ByteBuffer _bb) { return getRootAsPost(_bb, new Post()); }
  public static Post getRootAsPost(ByteBuffer _bb, Post obj) { _bb.order(ByteOrder.LITTLE_ENDIAN); return (obj.__init(_bb.getInt(_bb.position()) + _bb.position(), _bb)); }
  public Post __init(int _i, ByteBuffer _bb) { bb_pos = _i; bb = _bb; return this; }

  public String ID() { int o = __offset(4); return o != 0 ? __string(o + bb_pos) : null; }
  public ByteBuffer IDAsByteBuffer() { return __vector_as_bytebuffer(4, 1); }
  public String title() { int o = __offset(6); return o != 0 ? __string(o + bb_pos) : null; }
  public ByteBuffer titleAsByteBuffer() { return __vector_as_bytebuffer(6, 1); }
  public boolean active() { int o = __offset(8); return o != 0 ? 0!=bb.get(o + bb_pos) : false; }
  public long created() { int o = __offset(10); return o != 0 ? bb.getLong(o + bb_pos) : 0; }

  public static int createPost(FlatBufferBuilder builder,
      int ID,
      int title,
      boolean active,
      long created) {
    builder.startObject(4);
    Post.addCreated(builder, created);
    Post.addTitle(builder, title);
    Post.addID(builder, ID);
    Post.addActive(builder, active);
    return Post.endPost(builder);
  }

  public static void startPost(FlatBufferBuilder builder) { builder.startObject(4); }
  public static void addID(FlatBufferBuilder builder, int IDOffset) { builder.addOffset(0, IDOffset, 0); }
  public static void addTitle(FlatBufferBuilder builder, int titleOffset) { builder.addOffset(1, titleOffset, 0); }
  public static void addActive(FlatBufferBuilder builder, boolean active) { builder.addBoolean(2, active, false); }
  public static void addCreated(FlatBufferBuilder builder, long created) { builder.addLong(3, created, 0); }
  public static int endPost(FlatBufferBuilder builder) {
    int o = builder.endObject();
    return o;
  }
  public static void finishPostBuffer(FlatBufferBuilder builder, int offset) { builder.finish(offset); }
};

