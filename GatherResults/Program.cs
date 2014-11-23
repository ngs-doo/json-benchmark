using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;

namespace GatherResults
{
	class Program
	{
		private static string BenchPath = "../../../app";
		private static string JavaPath = @"C:\Program Files\Java\jdk1.7.0_21\bin";

		static void Main(string[] args)
		{
			if (args.Length > 0) BenchPath = args[0];
			bool exeExists = File.Exists(Path.Combine(BenchPath, "JsonBenchmark.exe"));
			bool jarExists = File.Exists(Path.Combine(BenchPath, "json-benchmark.jar"));
			if (!exeExists && !jarExists)
			{
				if (args.Length > 0 || !File.Exists("JsonBenchmark.exe"))
				{
					Console.WriteLine("Unable to find benchmark exe file: JsonBenchmark.exe in" + BenchPath);
					return;
				}
				if (args.Length > 0 || !File.Exists("json-benchmark.jar"))
				{
					Console.WriteLine("Unable to find benchmark jar file: json-benchmark.jar in" + BenchPath);
					return;
				}
				BenchPath = ".";
			}
			int repeat = args.Length > 1 ? int.Parse(args[1]) : 10;
			var startupSerialization = RunStartup(false, repeat);
			var startupBoth = RunStartup(true, repeat);
			var smallSerialization = RunSmall(false, repeat);
			var smallBoth = RunSmall(true, repeat);
			var standardSerialization = RunStandard(false, repeat);
			var standardBoth = RunStandard(true, repeat);
			var largeSerialization = RunLarge(false, repeat);
			var largeBoth = RunLarge(true, repeat);
			File.Copy("template.xlsx", "results.xlsx", true);
			using (var doc = NGS.Templater.Configuration.Factory.Open("results.xlsx"))
			{
				doc.Process(
					new
					{
						startupSerialization = startupSerialization,
						startupBoth = startupBoth,
						smallEventsSerialization = smallSerialization.Message,
						smallValuesSerialization = smallSerialization.Complex,
						smallAggregatesSerialization = smallSerialization.Post,
						smallEventsBoth = smallBoth.Message,
						smallValuesBoth = smallBoth.Complex,
						smallAggregatesBoth = smallBoth.Post,
						standardEventsSerialization = standardSerialization.DeletePost,
						standardAggregatesSerialization = standardSerialization.Post,
						standardEventsBoth = standardBoth.DeletePost,
						standardAggregatesBoth = standardBoth.Post,
						largeAggregatesSerialization = largeSerialization,
						largeAggregatesBoth = largeBoth,
					});
			}
			Process.Start("results.xlsx");
		}

		static List<Result> RunStartup(bool both, int times)
		{
			Console.Write("Gathering startup " + (both ? "serialization and deserialization" : "serialization only"));
			var result = new List<Result>();
			for (int i = 0; i < times; i++)
			{
				result.Add(GetherDuration("Small", both, 1).Extract(0));
				Console.Write("...");
				Console.Write(i + 1);
			}
			Console.WriteLine(" ... done");
			return result;
		}

		class SmallTest
		{
			public List<Result> Message = new List<Result>();
			public List<Result> Complex = new List<Result>();
			public List<Result> Post = new List<Result>();
		}

		static SmallTest RunSmall(bool both, int times)
		{
			Console.Write("Gathering small " + (both ? "serialization and deserialization" : "serialization only"));
			var result = new SmallTest();
			for (int i = 0; i < times; i++)
			{
				var d = GetherDuration("Small", both, 100000);
				Console.Write("...");
				Console.Write(i + 1);
				result.Message.Add(d.Extract(0));
				result.Complex.Add(d.Extract(1));
				result.Post.Add(d.Extract(2));
			}
			Console.WriteLine(" ... done");
			return result;
		}

		class StandardTest
		{
			public List<Result> DeletePost = new List<Result>();
			public List<Result> Post = new List<Result>();
		}

		static StandardTest RunStandard(bool both, int times)
		{
			Console.Write("Gathering standard " + (both ? "serialization and deserialization" : "serialization only"));
			var result = new StandardTest();
			for (int i = 0; i < times; i++)
			{
				var d = GetherDuration("Standard", both, 10000);
				Console.Write("...");
				Console.Write(i + 1);
				result.DeletePost.Add(d.Extract(0));
				result.Post.Add(d.Extract(1));
			}
			Console.WriteLine(" ... done");
			return result;
		}

		static List<Result> RunLarge(bool both, int times)
		{
			Console.Write("Gathering large " + (both ? "serialization and deserialization" : "serialization only"));
			var result = new List<Result>();
			for (int i = 0; i < times; i++)
			{
				result.Add(GetherDuration("Large", both, 100).Extract(0));
				Console.Write("...");
				Console.Write(i + 1);
			}
			Console.WriteLine(" ... done");
			return result;
		}

		static AggregatePass GetherDuration(string type, bool both, int count)
		{
			var NJ = RunSinglePass(true, "NewtonsoftJson", type, both, count);
			var NBF = RunSinglePass(true, "BakedInFull", type, both, count);
			var NBM = RunSinglePass(true, "BakedInMinimal", type, both, count);
			var NP = RunSinglePass(true, "ProtoBuf", type, both, count);
			var JJ = RunSinglePass(false, "Jackson", type, both, count);
			var JBF = RunSinglePass(false, "BakedInFull", type, both, count);
			var JBM = RunSinglePass(false, "BakedInMinimal", type, both, count);
			return new AggregatePass
			{
				NewtonsoftJson = NJ,
				NetBakedInFull = NBF,
				NetBakedInMinimal = NBM,
				Protobuf = NP,
				Jackson = JJ,
				JvmBakedInFull = JBF,
				JvmBakedInMinimal = JBM
			};
		}

		static List<Stats> RunSinglePass(bool exe, string serializer, string type, bool both, int count)
		{
			var processName = exe ? Path.Combine(BenchPath, "JsonBenchmark.exe") : Path.Combine(JavaPath, "java");
			var jarArg = exe ? string.Empty : "-jar \"" + Path.Combine(BenchPath, "json-benchmark.jar") + "\" ";
			var info = new ProcessStartInfo(processName, jarArg + serializer + " " + type + (both ? " Both " : " Serialization ") + count)
			{
				UseShellExecute = false,
				RedirectStandardOutput = true,
				RedirectStandardError = true,
				CreateNoWindow = true
			};
			var result = new List<Stats>();
			var process = Process.Start(info);
			process.WaitForExit();
			if (process.ExitCode != 0)
			{
				Console.WriteLine();
				var error = process.StandardError.ReadToEnd();
				process.Close();
				Console.WriteLine(error);
				result.Add(new Stats { Duration = -1, Size = -1 });
				result.Add(new Stats { Duration = -1, Size = -1 });
				result.Add(new Stats { Duration = -1, Size = -1 });
				return result;
			}
			var lines = process.StandardOutput.ReadToEnd().Split('\n');
			for (int i = 0; i < lines.Length / 3; i++)
			{
				var duration = lines[i * 3].Split('=');
				var size = lines[i * 3 + 1].Split('=');
				var errors = lines[i * 3 + 2].Split('=');
				result.Add(new Stats { Duration = int.Parse(duration[1]), Size = long.Parse(size[1]) });
			}
			return result;
		}
	}

	struct Stats
	{
		public int Duration;
		public long Size;
	}

	class AggregatePass
	{
		public List<Stats> NewtonsoftJson;
		public List<Stats> NetBakedInFull;
		public List<Stats> NetBakedInMinimal;
		public List<Stats> Jackson;
		public List<Stats> JvmBakedInFull;
		public List<Stats> JvmBakedInMinimal;
		public List<Stats> Protobuf;

		public Result Extract(int index)
		{
			return new Result
			{
				NewtonsoftJson = NewtonsoftJson[index],
				NetBakedInFull = NetBakedInFull[index],
				NetBakedInMinimal = NetBakedInMinimal[index],
				Jackson = Jackson[index],
				JvmBakedInFull = JvmBakedInFull[index],
				JvmBakedInMinimal = JvmBakedInMinimal[index],
				Protobuf = Protobuf[index],
			};
		}
	}

	class Result
	{
		public Stats NewtonsoftJson;
		public Stats NetBakedInFull;
		public Stats NetBakedInMinimal;
		public Stats Jackson;
		public Stats JvmBakedInFull;
		public Stats JvmBakedInMinimal;
		public Stats Protobuf;
	}
}
