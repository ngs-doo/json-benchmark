package hr.ngs.benchmark;

import hr.ngs.benchmark.serializers.*;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.Clock;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;

public class Main {

	private enum BenchTarget {
		DslJsonFull, DslJsonMinimal, Jackson, JacksonAfterburner,
		Boon, Gson, Genson, Alibaba, Flexjson,
		Kryo, FST,
		FlatBuf
	}

	private enum BenchSize {
		Small, Standard, Large
	}

	private enum BenchType {
		Serialization, Both, None, Check
	}

	private static <T extends Enum> String EnumTypes(T[] enums) {
		StringBuilder sb = new StringBuilder();
		sb.append(enums[0].name());
		for (int i = 1; i < enums.length; i++) {
			sb.append(" | ").append(enums[i].name());
		}
		return sb.toString();
	}

	private static class ByteStream extends ByteArrayOutputStream {
		public byte[] getBytes() {
			return this.buf;
		}
	}

	public static void main(String[] args) throws Exception {
		//args = new String[]{"Genson", "Small", "Check", "100"};
		if (args.length != 4) {
			System.out.printf(
					"Expected usage: java -jar json-benchamrk.jar (%s) (%s) (%s) n",
					EnumTypes(BenchTarget.values()),
					EnumTypes(BenchSize.values()),
					EnumTypes(BenchType.values()));
			System.exit(-1);
			return;
		}
		BenchTarget target;
		try {
			target = BenchTarget.valueOf(args[0]);
		} catch (Exception ex) {
			System.out.println("Unknown target found: " + args[0] + ". Supported targets: " + EnumTypes(BenchTarget.values()));
			System.exit(-2);
			return;
		}
		BenchSize size;
		try {
			size = BenchSize.valueOf(args[1]);
		} catch (Exception ex) {
			System.out.println("Unknown size found: " + args[1] + ". Supported targets: " + EnumTypes(BenchSize.values()));
			System.exit(-3);
			return;
		}
		BenchType type;
		try {
			type = BenchType.valueOf(args[2]);
		} catch (Exception ex) {
			System.out.println("Unknown type found: " + args[2] + ". Supported targets: " + EnumTypes(BenchType.values()));
			System.exit(-4);
			return;
		}
		int repeat;
		try {
			repeat = Integer.parseInt(args[3]);
		} catch (Exception ex) {
			System.out.println("Invalid repeat parameter: " + args[3]);
			System.exit(-5);
			return;
		}
		Serializer serializer;
		if (target == BenchTarget.Jackson) {
			serializer = new JacksonSerializer(false);
		} else if (target == BenchTarget.JacksonAfterburner) {
			serializer = new JacksonSerializer(true);
		} else if (target == BenchTarget.Alibaba) {
			serializer = new AlibabaSerializer();
		} else if (target == BenchTarget.Boon) {
			serializer = new BoonSerializer();
		} else if (target == BenchTarget.Flexjson) {
			serializer = new FlexJsonSerializer();
		} else if (target == BenchTarget.Gson) {
			serializer = new GsonSerializer();
		} else if (target == BenchTarget.Genson) {
			serializer = new GensonSerializer();
		} else if (target == BenchTarget.Kryo) {
			serializer = new KryoSerializer();
		} else if (target == BenchTarget.FST) {
			serializer = new FstSerializer();
		} else if (target == BenchTarget.FlatBuf) {
			serializer = new FlatBufSerializer();
		} else if (target == BenchTarget.DslJsonFull) {
			serializer = new DslJsonSerializer(false);
		} else if (target == BenchTarget.DslJsonMinimal) {
			serializer = new DslJsonSerializer(true);
		} else {
			System.out.println("Unmapped target ;(");
			System.exit(-99);
			return;
		}
		try {
			if (size == BenchSize.Small) {
				testSmall(repeat, serializer, type);
			} else if (size == BenchSize.Standard) {
				testStandard(repeat, serializer, type);
			} else {
				testLarge(repeat, serializer, type);
			}
		} catch (Exception ex) {
			reportError(ex);
		}
	}

	private static void reportStats(long start, long result, int incorrect) {
		long stop = System.nanoTime();
		long timediff = (stop - start) / 1000000;
		System.out.println("duration = " + timediff);
		System.out.println("size = " + result);
		System.out.println("invalid deserialization = " + incorrect);
	}

	private static void reportError(Exception ex) {
		System.out.println("duration = -1");
		System.out.println("size = -1");
		System.out.println("invalid deserialization = -1");
		System.out.println("duration = -1");
		System.out.println("size = -1");
		System.out.println("invalid deserialization = -1");
		System.out.println("duration = -1");
		System.out.println("size = -1");
		System.out.println("invalid deserialization = -1");
		System.out.println("error");
		//ex.printStackTrace(); ///.NET Process.WaitForExit doesn't work with such stacktrace error
		System.out.println(ex.getMessage());
		System.exit(-42);
	}

	private static void testSmall(int repeat, Serializer serializer, BenchType type) throws IOException {
		int incorrect = 0;
		ByteStream stream = new ByteStream();
		long start = System.nanoTime();
		long size = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.SmallObjects.Message message = new hr.ngs.benchmark.SmallObjects.Message();
			message.setMessage("some message " + i);
			message.setVersion(i);
			if (type == BenchType.None) continue;
			stream.reset();
			serializer.serialize(message, stream);
			size += stream.size();
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.SmallObjects.Message deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Message.class, stream.getBytes(), stream.size());
				if (type == BenchType.Check && !message.equals(deser)) {
					incorrect++;
					//throw new IOException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
		size = 0;
		start = System.nanoTime();
		incorrect = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.SmallObjects.Complex complex = new hr.ngs.benchmark.SmallObjects.Complex();
			complex.setX(BigDecimal.valueOf(i / 1000d));
			complex.setY(-i / 1000f);
			complex.setZ(i);
			if (type == BenchType.None) continue;
			stream.reset();
			serializer.serialize(complex, stream);
			size += stream.size();
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.SmallObjects.Complex deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Complex.class, stream.getBytes(), stream.size());
				if (type == BenchType.Check && !deser.equals(complex)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
		size = 0;
		OffsetDateTime now = OffsetDateTime.now(Clock.systemUTC());
		String ld = now.toLocalDate().toString();
		start = System.nanoTime();
		incorrect = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.SmallObjects.Post post = new hr.ngs.benchmark.SmallObjects.Post();
			post.setID(UUID.randomUUID());
			post.setTitle("some title " + i);
			post.setActive(i % 2 == 0);
			post.setCreated(now.plusMinutes(i).toLocalDate());
			if (type == BenchType.None) continue;
			stream.reset();
			serializer.serialize(post, stream);
			size += stream.size();
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.SmallObjects.Post deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Post.class, stream.getBytes(), stream.size());
				if (type == BenchType.Check && !deser.equals(post)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
	}

	private static void testStandard(int repeat, Serializer serializer, BenchType type) throws IOException {
		int incorrect = 0;
		ByteStream stream = new ByteStream();
		OffsetDateTime now = OffsetDateTime.now(Clock.systemUTC());
		LocalDate today = LocalDate.now();
		UUID[] uuids = new UUID[100];
		for (int i = 0; i < 100; i++) {
			uuids[i] = UUID.randomUUID();
		}
		String[][] tags = new String[][]{new String[0], new String[]{"JSON"}, new String[]{".NET", "Java", "benchmark"}};
		long size = 0;
		hr.ngs.benchmark.StandardObjects.PostState[] states = hr.ngs.benchmark.StandardObjects.PostState.values();
		long start = System.nanoTime();
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.StandardObjects.DeletePost delete = new hr.ngs.benchmark.StandardObjects.DeletePost();
			delete.setPostID(i);
			delete.setDeletedBy(i / 100);
			delete.setLastModified(now.plusSeconds(i));
			delete.setReason("no reason");
			if (i % 3 == 0) delete.setReferenceId(uuids[i % 100]);
			if (i % 5 == 0) delete.setState(states[i % 3]);
			if (i % 7 == 0) {
				delete.setVersions(new long[i % 100 + 1]);
				for (int x = 0; x <= i % 100; x++)
					delete.getVersions()[x] = i * x + x;
			}
			if (i % 2 == 0 && i % 10 != 0) {
				delete.setVotes(new ArrayList<>());
				for (int j = 0; j < i % 10; j++) {
					delete.getVotes().add((i + j) % 3 == 0 ? Boolean.TRUE : j % 2 == 0 ? Boolean.FALSE : null);
				}
			}
			if (type == BenchType.None) continue;
			stream.reset();
			serializer.serialize(delete, stream);
			size += stream.size();
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.StandardObjects.DeletePost deser = serializer.deserialize(hr.ngs.benchmark.StandardObjects.DeletePost.class, stream.getBytes(), stream.size());
				if (type == BenchType.Check && !delete.equals(deser)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
		size = 0;
		start = System.nanoTime();
		incorrect = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.StandardObjects.Post post = new hr.ngs.benchmark.StandardObjects.Post();
			post.setID(-i);
			post.setApproved(i % 2 == 0 ? null : now.plus(i, ChronoUnit.MILLIS));
			post.setVotes(new hr.ngs.benchmark.StandardObjects.Vote(i / 2, i / 3));
			post.setText("some text describing post " + i);
			post.setTitle("post title " + i);
			post.setState(states[i % 3]);
			String[] t = tags[i % 3];
			for (String aT : t) {
				post.getTags().add(aT);
			}
			post.setCreated(today.plusDays(i));
			for (int j = 0; j < i % 100; j++) {
				hr.ngs.benchmark.StandardObjects.Comment comment = new hr.ngs.benchmark.StandardObjects.Comment();
				comment.setCreated(today.plusDays(i + j));
				comment.setMessage("comment number " + i + " for " + j);
				comment.setVotes(new hr.ngs.benchmark.StandardObjects.Vote(j, j * 2));
				comment.setApproved(j % 3 != 0 ? null : now.plus(i, ChronoUnit.MILLIS));
				comment.setUser("some random user " + i);
				post.getComments().add(comment);
			}
			if (type == BenchType.None) continue;
			stream.reset();
			serializer.serialize(post, stream);
			size += stream.size();
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.StandardObjects.Post deser = serializer.deserialize(hr.ngs.benchmark.StandardObjects.Post.class, stream.getBytes(), stream.size());
				if (type == BenchType.Check && !post.equals(deser)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
	}

	private static void testLarge(int repeat, Serializer serializer, BenchType type) throws IOException {
		int incorrect = 0;
		OffsetDateTime now = OffsetDateTime.now(Clock.systemUTC());
		long size = 0;
		hr.ngs.benchmark.LargeObjects.Genre[] genresEnum = hr.ngs.benchmark.LargeObjects.Genre.values();
		ByteStream stream = new ByteStream();
		ArrayList<byte[]> illustrations = new ArrayList<>();
		Random rnd = new Random(1);
		for (int i = 0; i < 10; i++) {
			byte[] buf = new byte[256 * i * i * i];
			rnd.nextBytes(buf);
			illustrations.add(buf);
		}
		long start = System.nanoTime();
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.LargeObjects.Book book = new hr.ngs.benchmark.LargeObjects.Book();
			book.setID(-i);
			book.setAuthorId(i / 100);
			book.setPublished(i % 3 == 0 ? null : now.plusMinutes(i).toLocalDate());
			book.setTitle("book title " + i);
			hr.ngs.benchmark.LargeObjects.Genre[] genres = new hr.ngs.benchmark.LargeObjects.Genre[i % 2];
			for (int j = 0; j < i % 2; j++)
				genres[j] = genresEnum[(i + j) % 4];
			book.setGenres(genres);
			for (int j = 0; j < i % 20; j++)
				book.getChanges().add(now.plusMinutes(i).toLocalDate());
			for (int j = 0; j < i % 50; j++)
				book.getMetadata().put("key " + i + j, "value " + i + j);
			if (i % 3 == 0 || i % 7 == 0) book.setCover(illustrations.get(i % illustrations.size()));
			StringBuilder sb = new StringBuilder();
			for (int j = 0; j < i % 1000; j++) {
				sb.append("some text on page ").append(j);
				sb.append("more text for ").append(i);
				hr.ngs.benchmark.LargeObjects.Page page = new hr.ngs.benchmark.LargeObjects.Page();
				page.setText(sb.toString());
				for (int z = 0; z < i % 100; z++) {
					hr.ngs.benchmark.LargeObjects.Note note;
					if (z % 3 == 0) {
						hr.ngs.benchmark.LargeObjects.Headnote hn = new hr.ngs.benchmark.LargeObjects.Headnote();
						hn.setModifiedAt(now.plusSeconds(i));
						hn.setNote("headnote " + j + " at " + z);
						note = hn;
					} else {
						hr.ngs.benchmark.LargeObjects.Footnote fn = new hr.ngs.benchmark.LargeObjects.Footnote();
						fn.setCreateadAt(now.plusSeconds(i));
						fn.setNote("footnote " + j + " at " + z);
						fn.setIndex(i);
						note = fn;
					}
					if (z % 3 == 0)
						note.setWrittenBy("author " + j + " " + z);
					page.getNotes().add(note);
				}
				book.getPages().addLast(page);
			}
			if (type == BenchType.None) continue;
			stream.reset();
			serializer.serialize(book, stream);
			size += stream.size();
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.LargeObjects.Book deser = serializer.deserialize(hr.ngs.benchmark.LargeObjects.Book.class, stream.getBytes(), stream.size());
				if (type == BenchType.Check && !book.equals(deser)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
	}
}
