using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;

namespace GatherResults
{
	class Program
	{
		private static string BenchPath = "../../../app";
		private static string JavaPath = Environment.GetEnvironmentVariable("JAVA_HOME");

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
			var java = Path.Combine(JavaPath ?? ".", "bin", "java");
			var process =
				Process.Start(
					new ProcessStartInfo
					{
						FileName = java,
						Arguments = "-version",
						RedirectStandardOutput = true,
						UseShellExecute = false
					});
			var javaVersion = process.StandardOutput.ReadToEnd();
			Console.WriteLine(javaVersion);
			int repeat = args.Length > 1 ? int.Parse(args[1]) : 2;
			var smallSer1 = RunSmall(false, repeat, 1);
			var smallBoth1 = RunSmall(true, repeat, 1);
			var largeSer1 = RunLarge(false, repeat, 1);
			var largeBoth1 = RunLarge(true, repeat, 1);
			var smallSer100k = RunSmall(false, repeat, 100000);
			var smallBoth100k = RunSmall(true, repeat, 100000);
			var smallSer1m = RunSmall(false, repeat, 1000000);
			var smallBoth1m = RunSmall(true, repeat, 1000000);
			var smallSer10m = RunSmall(false, repeat, 10000000);
			var smallBoth10m = RunSmall(true, repeat, 10000000);
			var standardSer10k = RunStandard(false, repeat, 10000);
			var standardBoth10k = RunStandard(true, repeat, 10000);
			var standardSer100k = RunStandard(false, repeat, 100000);
			var standardBoth100k = RunStandard(true, repeat, 100000);
			var standardSer1m = RunStandard(false, repeat, 1000000);
			var standardBoth1m = RunStandard(true, repeat, 1000000);
			var largeSer100 = RunLarge(false, repeat, 100);
			var largeBoth100 = RunLarge(true, repeat, 100);
			var largeSer1k = RunLarge(false, repeat, 1000);
			var largeBoth1k = RunLarge(true, repeat, 1000);
			var largeSer10k = RunLarge(false, repeat, 10000);
			var largeBoth10k = RunLarge(true, repeat, 10000);
			File.Copy("template.xlsx", "results.xlsx", true);
			var vm = new ViewModel[]
			{
				new ViewModel("Startup times: SmallObject.Message",smallSer1.Message, smallBoth1.Message),
				new ViewModel("Startup times: LargeObjects.Book",largeSer1, largeBoth1),
				new ViewModel("100.000 SmallObjects.Message", smallSer100k.Message, smallBoth100k.Message),
				new ViewModel("1.000.000 SmallObjects.Message", smallSer1m.Message, smallBoth1m.Message),
				new ViewModel("10.000.000 SmallObjects.Message", smallSer10m.Message, smallBoth10m.Message),
				new ViewModel("100.000 SmallObjects.Complex", smallSer100k.Complex, smallBoth100k.Complex),
				new ViewModel("1.000.000 SmallObjects.Complex", smallSer1m.Complex, smallBoth1m.Complex),
				new ViewModel("10.000.000 SmallObjects.Complex", smallSer10m.Complex, smallBoth10m.Complex),
				new ViewModel("100.000 SmallObjects.Post", smallSer100k.Post, smallBoth100k.Post),
				new ViewModel("1.000.000 SmallObjects.Post", smallSer1m.Post, smallBoth1m.Post),
				new ViewModel("10.000.000 SmallObjects.Post", smallSer10m.Post, smallBoth10m.Post),
				new ViewModel("10.000 StandardObjects.DeletePost", standardSer10k.DeletePost, standardBoth10k.DeletePost),
				new ViewModel("100.000 StandardObjects.DeletePost", standardSer100k.DeletePost, standardBoth100k.DeletePost),
				new ViewModel("1.000.000 StandardObjects.DeletePost", standardSer1m.DeletePost, standardBoth1m.DeletePost),
				new ViewModel("10.000 StandardObjects.Post", standardSer10k.Post, standardBoth10k.Post),
				new ViewModel("100.000 StandardObjects.Post", standardSer100k.Post, standardBoth100k.Post),
				new ViewModel("1.000.000 StandardObjects.Post", standardSer1m.Post, standardBoth1m.Post),
				new ViewModel("100 LargeObjects.Book", largeSer100, largeBoth100),
				new ViewModel("1.000 LargeObjects.Book", largeSer1k, largeBoth1k),
				new ViewModel("10.000 LargeObjects.Book", largeSer10k, largeBoth10k),
			};
			var json = JsonConvert.SerializeObject(vm);
			File.WriteAllText("results.json", json);
			using (var doc = NGS.Templater.Configuration.Factory.Open("results.xlsx"))
				doc.Process(vm);
			Process.Start("results.xlsx");
		}

		class SmallTest
		{
			public List<Result> Message = new List<Result>();
			public List<Result> Complex = new List<Result>();
			public List<Result> Post = new List<Result>();
		}

		static SmallTest RunSmall(bool both, int times, int loops)
		{
			Console.Write("Gathering small (" + loops + ") " + (both ? "serialization and deserialization" : "serialization only"));
			var result = new SmallTest();
			for (int i = 0; i < times; i++)
			{
				var d = GetherDuration("Small", both, loops);
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

		static StandardTest RunStandard(bool both, int times, int loops)
		{
			Console.Write("Gathering standard (" + loops + ") " + (both ? "serialization and deserialization" : "serialization only"));
			var result = new StandardTest();
			for (int i = 0; i < times; i++)
			{
				var d = GetherDuration("Standard", both, loops);
				Console.Write("...");
				Console.Write(i + 1);
				result.DeletePost.Add(d.Extract(0));
				result.Post.Add(d.Extract(1));
			}
			Console.WriteLine(" ... done");
			return result;
		}

		static List<Result> RunLarge(bool both, int times, int loops)
		{
			Console.Write("Gathering large (" + loops + ") " + (both ? "serialization and deserialization" : "serialization only"));
			var result = new List<Result>();
			for (int i = 0; i < times; i++)
			{
				result.Add(GetherDuration("Large", both, loops).Extract(0));
				Console.Write("...");
				Console.Write(i + 1);
			}
			Console.WriteLine(" ... done");
			return result;
		}

		static AggregatePass GetherDuration(string type, bool both, int count)
		{
			var Net = RunSinglePass(true, "BakedInMinimal", type, null, count);
			var Jvm = RunSinglePass(false, "BakedInMinimal", type, null, count);
			var NJ = RunSinglePass(true, "NewtonsoftJson", type, both, count);
			var NBF = RunSinglePass(true, "BakedInFull", type, both, count);
			var NBM = RunSinglePass(true, "BakedInMinimal", type, both, count);
			var NP = RunSinglePass(true, "ProtoBuf", type, both, count);
			var JJ = RunSinglePass(false, "Jackson", type, both, count);
			var JBF = RunSinglePass(false, "BakedInFull", type, both, count);
			var JBM = RunSinglePass(false, "BakedInMinimal", type, both, count);
			return new AggregatePass
			{
				Net = Net,
				Jvm = Jvm,
				NewtonsoftJson = NJ,
				NetBakedInFull = NBF,
				NetBakedInMinimal = NBM,
				Protobuf = NP,
				Jackson = JJ,
				JvmBakedInFull = JBF,
				JvmBakedInMinimal = JBM
			};
		}

		static List<Stats> RunSinglePass(bool exe, string serializer, string type, bool? both, int count)
		{
			var processName = exe ? Path.Combine(BenchPath, "JsonBenchmark.exe") : Path.Combine(JavaPath ?? ".", "bin", "java");
			var jarArg = exe ? string.Empty : "-jar \"" + Path.Combine(BenchPath, "json-benchmark.jar") + "\" ";
			var what = both == null ? " None " : both == true ? " Both " : " Serialization ";
			var info = new ProcessStartInfo(processName, jarArg + serializer + " " + type + what + count)
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
			Console.WriteLine();
			for (int i = 0; i < lines.Length / 3; i++)
			{
				var duration = lines[i * 3].Split('=');
				var size = lines[i * 3 + 1].Split('=');
				var errors = lines[i * 3 + 2].Split('=');
				Console.WriteLine("duration = " + duration[1].Trim() + ", size = " + size[1].Trim() + ", errors = " + errors[1].Trim());
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
		public List<Stats> Net;
		public List<Stats> NewtonsoftJson;
		public List<Stats> NetBakedInFull;
		public List<Stats> NetBakedInMinimal;
		public List<Stats> Jvm;
		public List<Stats> Jackson;
		public List<Stats> JvmBakedInFull;
		public List<Stats> JvmBakedInMinimal;
		public List<Stats> Protobuf;

		public Result Extract(int index)
		{
			return new Result
			{
				Net = Net[index].Duration,
				Jvm = Jvm[index].Duration,
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
		public int Net;
		public int Jvm;
		public Stats NewtonsoftJson;
		public Stats NetBakedInFull;
		public Stats NetBakedInMinimal;
		public Stats Jackson;
		public Stats JvmBakedInFull;
		public Stats JvmBakedInMinimal;
		public Stats Protobuf;
	}

	class ViewModel
	{
		public string description;
		public List<Result> serialization;
		public List<Result> both;
		public ViewModel(string description, List<Result> serialization, List<Result> both)
		{
			this.description = description;
			this.serialization = serialization;
			this.both = both;
		}
	}
}
