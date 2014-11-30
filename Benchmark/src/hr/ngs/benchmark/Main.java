package hr.ngs.benchmark;

import com.dslplatform.client.Bootstrap;
import com.dslplatform.client.JsonSerialization;
import com.dslplatform.client.json.JsonObject;
import com.dslplatform.client.json.JsonReader;
import com.dslplatform.client.json.JsonWriter;
import com.dslplatform.patterns.ServiceLocator;
import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

public class Main {

	static enum BenchTarget {
		BakedInFull, BakedInMinimal, Jackson
	}

	enum BenchSize {
		Small, Standard, Large
	}

	enum BenchType {
		Serialization, Both, None
	}

	static <T extends Enum> String EnumTypes(T[] enums) {
		StringBuilder sb = new StringBuilder();
		sb.append(enums[0].name());
		for (int i = 1; i < enums.length; i++) {
			sb.append(" | " + enums[i].name());
		}
		return sb.toString();
	}

	interface Serializer {
		byte[] serialize(JsonObject arg) throws IOException;

		<T> T deserialize(Class<T> manifest, byte[] input) throws IOException;
	}

	public static void main(String[] args) throws Exception {
		//args = new String[]{"BakedInMinimal", "Standard", "Serialization", "100000"};
		if (args.length != 4) {
			System.out.printf(
					"Expected usage: java -jar json-benchamrk.jar (%s) (%s) (%s)",
					EnumTypes(BenchTarget.values()),
					EnumTypes(BenchSize.values()),
					EnumTypes(BenchType.values()));
			return;
		}
		BenchTarget target;
		try {
			target = BenchTarget.valueOf(args[0]);
		} catch (Exception ex) {
			System.out.println("Unknown target found: " + args[0] + ". Supported targets: " + EnumTypes(BenchTarget.values()));
			return;
		}
		BenchSize size;
		try {
			size = BenchSize.valueOf(args[1]);
		} catch (Exception ex) {
			System.out.println("Unknown size found: " + args[1] + ". Supported targets: " + EnumTypes(BenchSize.values()));
			return;
		}
		BenchType type;
		try {
			type = BenchType.valueOf(args[2]);
		} catch (Exception ex) {
			System.out.println("Unknown type found: " + args[2] + ". Supported targets: " + EnumTypes(BenchType.values()));
			return;
		}
		int repeat;
		try {
			repeat = Integer.parseInt(args[3]);
		} catch (Exception ex) {
			System.out.println("Invalid repeat parameter: " + args[3]);
			return;
		}
		Properties p = new Properties();
		p.setProperty("api-url", "http://localhost/");
		p.setProperty("package-name", "hr.ngs.benchmark");
		ServiceLocator locator = Bootstrap.init(p);
		Serializer serializer;
		if (target == BenchTarget.Jackson) {
			serializer = setupJackson(locator);
		} else if (target == BenchTarget.BakedInFull) {
			serializer = setupDslClient(locator, false);
		} else {
			serializer = setupDslClient(locator, true);
		}
		if (size == BenchSize.Small) {
			try {
				testSmall(repeat, serializer, type);
			} catch (Exception ex) {
				reportStats(new Date(), -1, repeat);
				reportStats(new Date(), -1, repeat);
				reportStats(new Date(), -1, repeat);
				System.out.println("error");
				System.out.println(ex.fillInStackTrace());
			}
		} else if (size == BenchSize.Standard) {
			try {
				testStandard(repeat, serializer, type);
			} catch (Exception ex) {
				reportStats(new Date(), -1, repeat);
				reportStats(new Date(), -1, repeat);
				System.out.println("error");
				System.out.println(ex.fillInStackTrace());
			}
		} else {
			try {
				testLarge(repeat, serializer, type);
			} catch (Exception ex) {
				reportStats(new Date(), -1, repeat);
				System.out.println("error");
				System.out.println(ex.fillInStackTrace());
			}
		}
	}

	static void reportStats(Date start, long result, int incorrect) {
		Date stop = new Date();
		long timediff = stop.getTime() - start.getTime();
		System.out.println("duration = " + timediff);
		System.out.println("size = " + result);
		System.out.println("invalid deserialization = " + incorrect);
	}

	static void testSmall(int repeat, Serializer serializer, BenchType type) throws IOException {
		int incorrect = 0;
		byte[] result;
		Date start = new Date();
		long size = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.SmallObjects.Message message = new hr.ngs.benchmark.SmallObjects.Message();
			message.setMessage("some message " + i);
			message.setVersion(i);
			if (type == BenchType.None) continue;
			result = serializer.serialize(message);
			size += result.length;
			if (type == BenchType.Both) {
				hr.ngs.benchmark.SmallObjects.Message deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Message.class, result);
				if (!message.equals(deser)) {
					incorrect++;
					//throw new IOException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
		size = 0;
		start = new Date();
		incorrect = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.SmallObjects.Complex complex = new hr.ngs.benchmark.SmallObjects.Complex();
			complex.setX(BigDecimal.valueOf(i / 1000f)).setY(-i / 1000f).setZ(i);
			if (type == BenchType.None) continue;
			result = serializer.serialize(complex);
			size += result.length;
			if (type == BenchType.Both) {
				hr.ngs.benchmark.SmallObjects.Complex deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Complex.class, result);
				if (!deser.equals(complex)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
		size = 0;
		DateTime now = new DateTime(new Date(), DateTimeZone.UTC);
		String ld = now.toLocalDate().toString();
		start = new Date();
		incorrect = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.SmallObjects.Post post = new hr.ngs.benchmark.SmallObjects.Post();
			post.setText("some text for post " + i);
			post.setTitle("some title " + i);
			post.setCreated(now.plusSeconds(i).toLocalDate());
			if (type == BenchType.None) continue;
			result = serializer.serialize(post);
			size += result.length;
			if (type == BenchType.Both) {
				hr.ngs.benchmark.SmallObjects.Post deser = serializer.deserialize(hr.ngs.benchmark.SmallObjects.Post.class, result);
				if (!deser.equals(post)) {
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
		UUID[] uuids = new UUID[100];
		for (int i = 0; i < 100; i++) {
			uuids[i] = UUID.randomUUID();
		}
		long size = 0;
		hr.ngs.benchmark.StandardObjects.PostState[] states = hr.ngs.benchmark.StandardObjects.PostState.values();
		byte[] result = null;
		Date start = new Date();
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
			if (type == BenchType.None) continue;
			result = serializer.serialize(delete);
			size += result.length;
			if (type == BenchType.Both) {
				hr.ngs.benchmark.StandardObjects.DeletePost deser = serializer.deserialize(hr.ngs.benchmark.StandardObjects.DeletePost.class, result);
				if (!delete.equals(deser)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
		size = 0;
		start = new Date();
		incorrect = 0;
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.StandardObjects.Post post = new hr.ngs.benchmark.StandardObjects.Post();
			post.setApproved(i % 2 == 0 ? null : now.plusMillis(i));
			post.setVotes(new hr.ngs.benchmark.StandardObjects.Vote(i / 2, i / 3));
			post.setText("some text describing post " + i);
			post.setTitle("post title " + i);
			post.setState(states[i % 3]);
			for (int j = 0; j < i % 100; j++) {
				hr.ngs.benchmark.StandardObjects.Comment comment = new hr.ngs.benchmark.StandardObjects.Comment();
				comment.setMessage("comment number " + i + " for " + j);
				comment.setVotes(new hr.ngs.benchmark.StandardObjects.Vote(j, j * 2));
				comment.setApproved(j % 3 != 0 ? null : now.plusMillis(i));
				comment.setUser("some random user " + i);
				comment.setPostID(post.getID()); //TODO: we should not be updating this, but since it's never persisted, it never gets updated
				comment.setIndex(j);
				post.getComments().add(comment);
			}
			if (type == BenchType.None) continue;
			result = serializer.serialize(post);
			size += result.length;
			if (type == BenchType.Both) {
				hr.ngs.benchmark.StandardObjects.Post deser = serializer.deserialize(hr.ngs.benchmark.StandardObjects.Post.class, result);
				if (!post.equals(deser)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
	}

	static void testLarge(int repeat, Serializer serializer, BenchType type) throws IOException {
		int incorrect = 0;
		DateTime now = DateTime.now();
		long size = 0;
		hr.ngs.benchmark.LargeObjects.Genre[] genresEnum = hr.ngs.benchmark.LargeObjects.Genre.values();
		byte[] result = null;
		ArrayList<byte[]> illustrations = new ArrayList<byte[]>();
		Random rnd = new Random(1);
		for (int i = 0; i < 10; i++) {
			byte[] buf = new byte[256 * i * i * i];
			rnd.nextBytes(buf);
			illustrations.add(buf);
		}
		Date start = new Date();
		for (int i = 0; i < repeat; i++) {
			hr.ngs.benchmark.LargeObjects.Book book = new hr.ngs.benchmark.LargeObjects.Book();
			book.setAuthorId(i / 100);
			book.setPublished(i % 3 == 0 ? null : now.plusMinutes(i).toLocalDate());
			book.setTitle("book title " + i);
			ArrayList<hr.ngs.benchmark.LargeObjects.Genre> genres = new ArrayList<hr.ngs.benchmark.LargeObjects.Genre>();
			for (int j = 0; j < i % 2; j++)
				genres.add(genresEnum[(i + j) % 4]);
			book.setGenres(genres.toArray(new hr.ngs.benchmark.LargeObjects.Genre[genres.size()]));
			for (int j = 0; j < i % 20; j++)
				book.getChanges().add(now.plusMinutes(i).toLocalDate());
			for (int j = 0; j < i % 50; j++)
				book.getMetadata().put("key " + i + j, "value " + i + j);
			if (i % 3 == 0 || i % 7 == 0) book.setCover(illustrations.get(i % illustrations.size()));
			StringBuilder sb = new StringBuilder();
			for (int j = 0; j < i % 1000; j++) {
				sb.append("some text on page " + j);
				sb.append("more text for " + i);
				hr.ngs.benchmark.LargeObjects.Page page = new hr.ngs.benchmark.LargeObjects.Page();
				page.setText(sb.toString());
				page.setBookID(book.getID()); //TODO: we should not be updating this, but since it's never persisted, it never gets updated
				page.setIndex(j);
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
			if (type == BenchType.Both) {
				hr.ngs.benchmark.LargeObjects.Book deser = serializer.deserialize(hr.ngs.benchmark.LargeObjects.Book.class, result);
				if (!book.equals(deser)) {
					incorrect++;
					//throw new SerializationException("not equal");
				}
			}
		}
		reportStats(start, size, incorrect);
	}

	private static final HashMap<Class<?>, JsonReader.ReadJsonObject<JsonObject>> jsonReaderes = new HashMap<Class<?>, JsonReader.ReadJsonObject<JsonObject>>();

	@SuppressWarnings("unchecked")
	private static JsonReader.ReadJsonObject<JsonObject> getReader(final Class<?> manifest) {
		try {
			JsonReader.ReadJsonObject<JsonObject> reader = jsonReaderes.get(manifest);
			if (reader == null) {
				reader = (JsonReader.ReadJsonObject<JsonObject>) manifest.getField("JSON_READER").get(null);
				jsonReaderes.put(manifest, reader);
			}
			return reader;
		} catch (Exception ignore) {
			return null;
		}
	}

	static Serializer setupDslClient(final ServiceLocator locator, final boolean minimal) throws IOException {
		final JsonWriter sw = new JsonWriter();
		return new Serializer() {
			@Override
			public byte[] serialize(JsonObject arg) throws IOException {
				arg.serialize(sw, minimal);
				return sw.toBytes();
			}

			@SuppressWarnings("unchecked")
			@Override
			public <T> T deserialize(Class<T> manifest, byte[] input) throws IOException {
				JsonReader.ReadJsonObject<JsonObject> reader = getReader(manifest);
				JsonReader json = new JsonReader(input, locator);
				if (json.getNextToken() == '{') {
					return (T) reader.deserialize(json, locator);
				} else throw new IOException("Expecting {");
			}
		};
	}

	static Serializer setupJackson(ServiceLocator locator) throws IOException {
		final JsonSerialization json = locator.resolve(JsonSerialization.class);
		return new Serializer() {
			@Override
			public byte[] serialize(JsonObject arg) throws IOException {
				return JsonSerialization.serializeBytes(arg);
			}

			@Override
			public <T> T deserialize(Class<T> manifest, byte[] input) throws IOException {
				return json.deserialize(manifest, input);
			}
		};
	}
}
