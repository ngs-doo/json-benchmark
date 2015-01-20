using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using Newtonsoft.Json;

namespace GatherResults
{
	class Program
	{
		private static string BenchPath = "../../../app";
		private static string JavaPath = Environment.GetEnvironmentVariable("JAVA_HOME");

		static void Main(string[] args)
		{
			if (args.Length == 2 && args[0] == "import" && File.Exists(args[1]))
			{
				File.Copy("template.xlsx", "results.xlsx", true);
				var vms = JsonConvert.DeserializeObject<ViewModel[]>(File.ReadAllText(args[1]));
				using (var doc = NGS.Templater.Configuration.Factory.Open("results.xlsx"))
					doc.Process(vms);
				Process.Start("results.xlsx");
				return;
			}
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
			var small1 = RunSmall(repeat, 1);
			var large1 = RunLarge(repeat, 1);
			var small100k = RunSmall(repeat, 100000);
			var small1m = RunSmall(repeat, 1000000);
			var small10m = RunSmall(repeat, 10000000);
			var std10k = RunStandard(repeat, 10000);
			var std100k = RunStandard(repeat, 100000);
			var std1m = RunStandard(repeat, 1000000);
			var large100 = RunLarge(repeat, 100);
			var large1k = RunLarge(repeat, 1000);
			File.Copy("template.xlsx", "results.xlsx", true);
			var vm = new ViewModel[]
			{
				ViewModel.Create("Startup times: SmallObject.Message",small1, t => t.Message),
				new ViewModel("Startup times: LargeObjects.Book",large1),
				ViewModel.Create("100.000 SmallObjects.Message", small100k, t => t.Message),
				ViewModel.Create("1.000.000 SmallObjects.Message", small1m, t => t.Message),
				ViewModel.Create("10.000.000 SmallObjects.Message", small10m, t => t.Message),
				ViewModel.Create("100.000 SmallObjects.Complex", small100k, t => t.Complex),
				ViewModel.Create("1.000.000 SmallObjects.Complex", small1m, t => t.Complex),
				ViewModel.Create("10.000.000 SmallObjects.Complex", small10m, t => t.Complex),
				ViewModel.Create("100.000 SmallObjects.Post", small100k, t => t.Post),
				ViewModel.Create("1.000.000 SmallObjects.Post", small1m, t => t.Post),
				ViewModel.Create("10.000.000 SmallObjects.Post", small10m, t => t.Post),
				ViewModel.Create("10.000 StandardObjects.DeletePost", std10k, t => t.DeletePost),
				ViewModel.Create("100.000 StandardObjects.DeletePost", std100k, t => t.DeletePost),
				ViewModel.Create("1.000.000 StandardObjects.DeletePost", std1m, t => t.DeletePost),
				ViewModel.Create("10.000 StandardObjects.Post", std10k, t => t.Post),
				ViewModel.Create("100.000 StandardObjects.Post", std100k, t => t.Post),
				ViewModel.Create("1.000.000 StandardObjects.Post", std1m, t => t.Post),
				new ViewModel("100 LargeObjects.Book", large100),
				new ViewModel("1.000 LargeObjects.Book", large1k),
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

		static Run<SmallTest> RunSmall(int times, int loops)
		{
			return new Run<SmallTest>
			{
				Serialization = RunSmall(false, times, loops),
				Both = RunSmall(true, times, loops)
			};
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

		static Run<StandardTest> RunStandard(int times, int loops)
		{
			return new Run<StandardTest>
			{
				Serialization = RunStandard(false, times, loops),
				Both = RunStandard(true, times, loops)
			};
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

		static Run<List<Result>> RunLarge(int times, int loops)
		{
			return new Run<List<Result>>
			{
				Serialization = RunLarge(false, times, loops),
				Both = RunLarge(true, times, loops)
			};
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
			RunSinglePass("Warmup .NET", true, "BakedInMinimal", type, null, 1);
			var Net = RunSinglePass("Instance .NET", true, "BakedInMinimal", type, null, count);
			var NJ = RunSinglePass("NewtonsoftJson", true, "NewtonsoftJson", type, both, count);
			var NBF = RunSinglePass("Revenj full", true, "BakedInFull", type, both, count);
			var NBM = RunSinglePass("Revenj minimal", true, "BakedInMinimal", type, both, count);
			var NP = RunSinglePass("Protobuf.NET", true, "ProtoBuf", type, both, count);
			RunSinglePass("Warmup JVM", false, "BakedInMinimal", type, null, 1); //warmup
			var Jvm = RunSinglePass("Instance JVM", false, "BakedInMinimal", type, null, count);
			var JJ = RunSinglePass("Jackson", false, "Jackson", type, both, count);
			var JBF = RunSinglePass("DSL client Java full", false, "BakedInFull", type, both, count);
			var JBM = RunSinglePass("DSL client Java minimal", false, "BakedInMinimal", type, both, count);
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

		static List<Stats> RunSinglePass(string description, bool exe, string serializer, string type, bool? both, int count)
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
				Console.WriteLine(description + ": duration = " + duration[1].Trim() + ", size = " + size[1].Trim() + ", errors = " + errors[1].Trim());
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

	class Run<T>
	{
		public T Serialization;
		public T Both;
	}

	class ViewModel
	{
		public string description;
		public List<Result> serialization;
		public List<Result> both;
		public ViewModel() { }
		public ViewModel(string description, Run<List<Result>> run)
			: this(description, run.Serialization, run.Both) { }
		private ViewModel(string description, List<Result> serialization, List<Result> both)
		{
			this.description = description;
			this.serialization = serialization;
			this.both = both;
		}

		public static ViewModel Create<T>(string description, Run<T> run, Func<T, List<Result>> extract)
		{
			return new ViewModel(description, extract(run.Serialization), extract(run.Both));
		}
	}
}
