using Revenj.Utility;
using System;
using System.Diagnostics;

namespace JsonBenchmark
{
	class Program
	{
		enum BenchTarget
		{
			RevenjNewtonsoftJson, RevenjJsonFull, RevenjJsonMinimal,
			NewtonsoftJson, Jil, fastJSON, ServiceStack, BondJson, NetJSON,
			ProtoBuf, BondBinary, Utf8Json
		}

		enum BenchSize
		{
			Small, Standard, Large
		}

		enum BenchType
		{
			Serialization, Both, None, Check
		}

		static int Main(string[] args)
		{
			//args = new[] { "BondBinary", "Standard", "Check", "100" };
			//args = new[] { "RevenjNewtonsoftJson", "Large", "Serialization", "100" };
			var gc0 = GC.CollectionCount(0);
			var gc1 = GC.CollectionCount(1);
			var gc2 = GC.CollectionCount(2);
			if (args.Length != 4)
			{
				Console.WriteLine(
					"Expected usage: JsonBenchamrk.exe ({0}) ({1}) ({2}) repeat",
					string.Join(" | ", Enum.GetNames(typeof(BenchTarget))),
					string.Join(" | ", Enum.GetNames(typeof(BenchSize))),
					string.Join(" | ", Enum.GetNames(typeof(BenchType))));
				return -1;
			}
			BenchTarget target;
			if (!Enum.TryParse<BenchTarget>(args[0], out target))
			{
				Console.WriteLine("Unknown target found: " + args[0] + ". Supported targets: " + string.Join(" | ", Enum.GetNames(typeof(BenchTarget))));
				return -2;
			}
			BenchSize size;
			if (!Enum.TryParse<BenchSize>(args[1], out size))
			{
				Console.WriteLine("Unknown size found: " + args[1] + ". Supported size: " + string.Join(" | ", Enum.GetNames(typeof(BenchSize))));
				return -3;
			}
			BenchType type;
			if (!Enum.TryParse<BenchType>(args[2], out type))
			{
				Console.WriteLine("Unknown type found: " + args[2] + ". Supported types: " + string.Join(" | ", Enum.GetNames(typeof(BenchType))));
				return -4;
			}
			int repeat;
			if (!int.TryParse(args[3], out repeat))
			{
				Console.WriteLine("Invalid repeat parameter: " + args[3]);
				return -5;
			}
			Action<object, ChunkedMemoryStream> serialize;
			Func<ChunkedMemoryStream, Type, object> deserialize;
			switch (target)
			{
				case BenchTarget.NewtonsoftJson:
					LibrarySetup.SetupNewtonsoftJson(out serialize, out deserialize);
					break;
				case BenchTarget.RevenjNewtonsoftJson:
					LibrarySetup.SetupNewtonsoftJson(out serialize, out deserialize);
					break;
				case BenchTarget.BondJson:
					LibrarySetup.SetupBondJson(out serialize, out deserialize);
					break;
				case BenchTarget.BondBinary:
					LibrarySetup.SetupBondBinary(out serialize, out deserialize);
					break;
				case BenchTarget.Jil:
					LibrarySetup.SetupJil(out serialize, out deserialize);
					break;
				case BenchTarget.fastJSON:
					LibrarySetup.SetupFastJson(out serialize, out deserialize);
					break;
				case BenchTarget.ServiceStack:
					LibrarySetup.SetupServiceStack(out serialize, out deserialize);
					break;
				case BenchTarget.NetJSON:
					LibrarySetup.SetupNetJSON(out serialize, out deserialize);
					break;
                case BenchTarget.Utf8Json:
                    LibrarySetup.SetupUtf8Json(out serialize, out deserialize);
                    break;
                case BenchTarget.ProtoBuf:
					LibrarySetup.SetupProtobuf(out serialize, out deserialize);
					break;
				case BenchTarget.RevenjJsonFull:
					LibrarySetup.SetupRevenj(out serialize, out deserialize, false);
					break;
				case BenchTarget.RevenjJsonMinimal:
					LibrarySetup.SetupRevenj(out serialize, out deserialize, true);
					break;
				default:
					Console.WriteLine("Unwired bench type: " + type);
					return -123;
			}
			var ms = new ChunkedMemoryStream();
			switch (size)
			{
				case BenchSize.Small:
					try
					{
						if (target == BenchTarget.BondBinary || target == BenchTarget.BondJson)
						{
							Func<int, SmallObjects.Bond.Message> factory1 =
								i => Models.Small.Message.Factory<SmallObjects.Bond.Message>(i);
							Func<int, SmallObjects.Bond.Complex> factory2 =
								i => Models.Small.Complex.Factory<SmallObjects.Bond.Complex>(i);
							Func<int, SmallObjects.Bond.Post> factory3 =
								i => Models.Small.Post.Factory<SmallObjects.Bond.Post>(i);
							RunLoop(repeat, serialize, deserialize, type, ms, factory1);
							RunLoop(repeat, serialize, deserialize, type, ms, factory2);
							RunLoop(repeat, serialize, deserialize, type, ms, factory3);
						}
						else if (target == BenchTarget.RevenjJsonFull || target == BenchTarget.RevenjJsonMinimal
							|| target == BenchTarget.RevenjNewtonsoftJson)
						{
							Func<int, SmallObjects.Message> factory1 = i => Models.Small.Message.Factory<SmallObjects.Message>(i);
							Func<int, SmallObjects.Complex> factory2 = i => Models.Small.Complex.Factory<SmallObjects.Complex>(i);
							Func<int, SmallObjects.Post> factory3 = i => Models.Small.Post.Factory<SmallObjects.Post>(i);
							RunLoop(repeat, serialize, deserialize, type, ms, factory1);
							RunLoop(repeat, serialize, deserialize, type, ms, factory2);
							RunLoop(repeat, serialize, deserialize, type, ms, factory3);
						}
						else
						{
							Func<int, Models.Small.Message> factory1 = i => Models.Small.Message.Factory<Models.Small.Message>(i);
							Func<int, Models.Small.Complex> factory2 = i => Models.Small.Complex.Factory<Models.Small.Complex>(i);
							Func<int, Models.Small.Post> factory3 = i => Models.Small.Post.Factory<Models.Small.Post>(i);
							RunLoop(repeat, serialize, deserialize, type, ms, factory1);
							RunLoop(repeat, serialize, deserialize, type, ms, factory2);
							RunLoop(repeat, serialize, deserialize, type, ms, factory3);
						}
					}
					catch (Exception ex)
					{
						ReportStatsAndRestart(null, -1, repeat);
						ReportStatsAndRestart(null, -1, repeat);
						ReportStatsAndRestart(null, -1, repeat);
						Console.WriteLine("error");
						Console.WriteLine(ex.Message);
						return -41;
					}
					break;
				case BenchSize.Standard:
					try
					{
						if (target == BenchTarget.BondBinary || target == BenchTarget.BondJson)
						{
							Func<int, StandardObjects.Bond.PostState> cast = i => (StandardObjects.Bond.PostState)i;
							Func<int, StandardObjects.Bond.DeletePost> factory1 =
								i => Models.Standard.DeletePost.Factory<StandardObjects.Bond.DeletePost, StandardObjects.Bond.PostState>(i, cast);
							Func<int, StandardObjects.Bond.Post> factory2 =
								i => Models.Standard.Post.Factory<StandardObjects.Bond.Post, StandardObjects.Bond.Vote, StandardObjects.Bond.PostState, StandardObjects.Bond.Comment>(i, cast);
							RunLoop(repeat, serialize, deserialize, type, ms, factory1);
							RunLoop(repeat, serialize, deserialize, type, ms, factory2);
						}
						else if (target == BenchTarget.RevenjJsonFull || target == BenchTarget.RevenjJsonMinimal
							|| target == BenchTarget.RevenjNewtonsoftJson)
						{
							Func<int, StandardObjects.PostState> cast = i => (StandardObjects.PostState)i;
							Func<int, StandardObjects.DeletePost> factory1 =
								i => Models.Standard.DeletePost.Factory<StandardObjects.DeletePost, StandardObjects.PostState>(i, cast);
							Func<int, StandardObjects.Post> factory2 =
								i => Models.Standard.Post.Factory<StandardObjects.Post, StandardObjects.Vote, StandardObjects.PostState, StandardObjects.Comment>(i, cast);
							RunLoop(repeat, serialize, deserialize, type, ms, factory1);
							RunLoop(repeat, serialize, deserialize, type, ms, factory2);
						}
						else
						{
							Func<int, Models.Standard.PostState> cast = i => (Models.Standard.PostState)i;
							Func<int, Models.Standard.DeletePost> factory1 = i => Models.Standard.DeletePost.Factory<Models.Standard.DeletePost, Models.Standard.PostState>(i, cast);
							Func<int, Models.Standard.Post> factory2 =
								i => Models.Standard.Post.Factory<Models.Standard.Post, Models.Standard.Vote, Models.Standard.PostState, Models.Standard.Comment>(i, cast);
							RunLoop(repeat, serialize, deserialize, type, ms, factory1);
							RunLoop(repeat, serialize, deserialize, type, ms, factory2);
						}
					}
					catch (Exception ex)
					{
						ReportStatsAndRestart(null, -1, repeat);
						ReportStatsAndRestart(null, -1, repeat);
						Console.WriteLine("error");
						Console.WriteLine(ex.Message);
						return -42;
					}
					break;
				default:
					try
					{
						if (target == BenchTarget.RevenjJsonFull || target == BenchTarget.RevenjJsonMinimal
							|| target == BenchTarget.RevenjNewtonsoftJson)
						{
							Func<int, LargeObjects.Genre> cast = i => (LargeObjects.Genre)i;
							Func<int, LargeObjects.Book> factory =
								i => Models.Large.Book.Factory<LargeObjects.Book, LargeObjects.Genre, LargeObjects.Page, LargeObjects.Headnote, LargeObjects.Footnote>(i, cast);
							RunLoop(repeat, serialize, deserialize, type, ms, factory);
						}
						else
						{
							Func<int, Models.Large.Genre> cast = i => (Models.Large.Genre)i;
							Func<int, Models.Large.Book> factory =
								i => Models.Large.Book.Factory<Models.Large.Book, Models.Large.Genre, Models.Large.Page, Models.Large.Headnote, Models.Large.Footnote>(i, cast);
							RunLoop(repeat, serialize, deserialize, type, ms, factory);
						}
					}
					catch (Exception ex)
					{
						ReportStatsAndRestart(null, -1, repeat);
						Console.WriteLine("error");
						Console.WriteLine(ex.Message);
						return -43;
					}
					break;
			}
			//Console.WriteLine("GC0: " + (GC.CollectionCount(0) - gc0));
			//Console.WriteLine("GC1: " + (GC.CollectionCount(1) - gc1));
			//Console.WriteLine("GC2: " + (GC.CollectionCount(2) - gc2));
			return 0;
		}

		static void ReportStatsAndRestart(Stopwatch sw, long size, int incorrect)
		{
			Console.WriteLine("duration = " + (sw != null ? sw.ElapsedMilliseconds : -1));
			Console.WriteLine("size = " + size);
			Console.WriteLine("invalid deserialization = " + incorrect);
			if (sw != null)
				sw.Restart();
		}

		private static void RunLoop<T>(
			int repeat,
			Action<object, ChunkedMemoryStream> serialize,
			Func<ChunkedMemoryStream, Type, object> deserialize,
			BenchType type,
			ChunkedMemoryStream ms,
			Func<int, T> factory) where T : IEquatable<T>
		{
			var sw = Stopwatch.StartNew();
			var incorrect = 0;
			long size = 0;
			for (int i = 0; i < repeat; i++)
			{
				ms.SetLength(0);
				var instance = factory(i);
				if (type == BenchType.None) continue;
				serialize(instance, ms);
				size += ms.Position;
				if (type == BenchType.Both || type == BenchType.Check)
				{
					ms.Position = 0;
					var deser = (T)deserialize(ms, typeof(T));
					if (type == BenchType.Check && !instance.Equals(deser))
					{
						incorrect++;
						//throw new SerializationException("not equal");
					}
				}
			}
			ReportStatsAndRestart(sw, size, incorrect);
		}
	}
}
