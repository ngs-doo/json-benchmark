package hr.ngs.benchmark;

import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

public class Main {

	static enum BenchTarget {
		DslJavaFull, DslJavaMinimal, Jackson, JacksonAfterburner,
		Boon, Gson, Genson, Alibaba, Flexjson
	}

	enum BenchSize {
		Small, Standard, Large
	}

	enum BenchType {
		Serialization, Both, None, Check
	}

	static <T extends Enum> String EnumTypes(T[] enums) {
		StringBuilder sb = new StringBuilder();
		sb.append(enums[0].name());
		for (int i = 1; i < enums.length; i++) {
			sb.append(" | ").append(enums[i].name());
		}
		return sb.toString();
	}

	public static void main(String[] args) throws Exception {
		//args = new String[]{"Flexjson", "Small", "Check", "100"};
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
			serializer = SetupLibraries.setupJackson();
		} else if (target == BenchTarget.JacksonAfterburner) {
			serializer = SetupLibraries.setupJacksonAfterburner();
		} else if (target == BenchTarget.Alibaba) {
			serializer = SetupLibraries.setupAlibaba();
		} else if (target == BenchTarget.Boon) {
			serializer = SetupLibraries.setupBoon();
		} else if (target == BenchTarget.Flexjson) {
			serializer = SetupLibraries.setupFlexjson();
		} else if (target == BenchTarget.Gson) {
			serializer = SetupLibraries.setupGson();
		} else if (target == BenchTarget.Genson) {
			serializer = SetupLibraries.setupGenson();
		} else if (target == BenchTarget.DslJavaFull) {
			serializer = SetupLibraries.setupDslClient(false);
		} else {
			serializer = SetupLibraries.setupDslClient(true);
		}
		if (size == BenchSize.Small) {
			try {
				testSmall(repeat, serializer, type);
			} catch (Exception ex) {
				reportStats(System.nanoTime(), -1, repeat);
				reportStats(System.nanoTime(), -1, repeat);
				reportStats(System.nanoTime(), -1, repeat);
				System.out.println("error");
				System.out.println(ex.fillInStackTrace());
				System.exit(-41);
			}
		} else if (size == BenchSize.Standard) {
			try {
				testStandard(repeat, serializer, type);
			} catch (Exception ex) {
				reportStats(System.nanoTime(), -1, repeat);
				reportStats(System.nanoTime(), -1, repeat);
				System.out.println("error");
				System.out.println(ex.fillInStackTrace());
				System.exit(-42);
			}
		} else {
			try {
				testLarge(repeat, serializer, type);
			} catch (Exception ex) {
				reportStats(System.nanoTime(), -1, repeat);
				System.out.println("error");
				System.out.println(ex.fillInStackTrace());
				System.exit(-43);
			}
		}
	}

	static void reportStats(long start, long result, int incorrect) {
		long stop = System.nanoTime();
		long timediff = (stop - start) / 1000000;
		System.out.println("duration = " + timediff);
		System.out.println("size = " + result);
		System.out.println("invalid deserialization = " + incorrect);
	}

	static void testSmall(int repeat, Serializer serializer, BenchType type) throws IOException {
		int incorrect = 0;
		Bytes result;
		long start = System.nanoTime();
		long size = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.SmallObjects.Message message = new hr.ngs.benchmark.SmallObjects.Message();
			message.setMessage("some message " + i);
			message.setVersion(i);
			if (type == BenchType.None) continue;
			result = serializer.serialize(message);
			size += result.length;
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.SmallObjects.Message deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Message.class, result);
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
			complex.setX(BigDecimal.valueOf(i / 1000d)).setY(-i / 1000f).setZ(i);
			if (type == BenchType.None) continue;
			result = serializer.serialize(complex);
			size += result.length;
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.SmallObjects.Complex deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Complex.class, result);
				if (type == BenchType.Check && !deser.equals(complex)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
		size = 0;
		DateTime now = new DateTime(new Date(), DateTimeZone.UTC);
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
			result = serializer.serialize(post);
			size += result.length;
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.SmallObjects.Post deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Post.class, result);
				if (type == BenchType.Check && !deser.equals(post)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
	}

	static void testStandard(int repeat, Serializer serializer, BenchType type) throws IOException {
		int incorrect = 0;
		DateTime now = new DateTime(new Date(), DateTimeZone.UTC);
		LocalDate today = LocalDate.now();
		UUID[] uuids = new UUID[100];
		for (int i = 0; i < 100; i++) {
			uuids[i] = UUID.randomUUID();
		}
		String[][] tags = new String[][]{new String[0], new String[]{"JSON"}, new String[]{".NET", "Java", "benchmark"}};
		long size = 0;
		hr.ngs.benchmark.StandardObjects.PostState[] states = hr.ngs.benchmark.StandardObjects.PostState.values();
		Bytes result;
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
				delete.setVotes(new ArrayList<Boolean>());
				for (int j = 0; j < i % 10; j++) {
					delete.getVotes().add((i + j) % 3 == 0 ? Boolean.TRUE : j % 2 == 0 ? Boolean.FALSE : null);
				}
			}
			if (type == BenchType.None) continue;
			result = serializer.serialize(delete);
			size += result.length;
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.StandardObjects.DeletePost deser = serializer.deserialize(hr.ngs.benchmark.StandardObjects.DeletePost.class, result);
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
			post.setApproved(i % 2 == 0 ? null : now.plusMillis(i));
			post.setVotes(new hr.ngs.benchmark.StandardObjects.Vote(i / 2, i / 3));
			post.setText("some text describing post " + i);
			post.setTitle("post title " + i);
			post.setState(states[i % 3]);
			String[] t = tags[i % 3];
			for (int j = 0; j < t.length; j++) {
				post.getTags().add(t[j]);
			}
			post.setCreated(today.plusDays(i));
			for (int j = 0; j < i % 100; j++) {
				hr.ngs.benchmark.StandardObjects.Comment comment = new hr.ngs.benchmark.StandardObjects.Comment();
				comment.setCreated(today.plusDays(i + j));
				comment.setMessage("comment number " + i + " for " + j);
				comment.setVotes(new hr.ngs.benchmark.StandardObjects.Vote(j, j * 2));
				comment.setApproved(j % 3 != 0 ? null : now.plusMillis(i));
				comment.setUser("some random user " + i);
				post.getComments().add(comment);
			}
			if (type == BenchType.None) continue;
			result = serializer.serialize(post);
			size += result.length;
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.StandardObjects.Post deser = serializer.deserialize(hr.ngs.benchmark.StandardObjects.Post.class, result);
				if (type == BenchType.Check && !post.equals(deser)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
	}

	static void testLarge(int repeat, Serializer serializer, BenchType type) throws IOException {
		int incorrect = 0;
		DateTime now = new DateTime(new Date(), DateTimeZone.UTC);
		long size = 0;
		hr.ngs.benchmark.LargeObjects.Genre[] genresEnum = hr.ngs.benchmark.LargeObjects.Genre.values();
		Bytes result;
		ArrayList<byte[]> illustrations = new ArrayList<byte[]>();
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
			result = serializer.serialize(book);
			size += result.length;
			if (type == BenchType.Both || type == BenchType.Check) {
				hr.ngs.benchmark.LargeObjects.Book deser = serializer.deserialize(hr.ngs.benchmark.LargeObjects.Book.class, result);
				if (type == BenchType.Check && !book.equals(deser)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
	}
}
