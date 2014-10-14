using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;

namespace GatherResults
{
	class Program
	{
		private static string BenchExe = @"..\..\..\Benchmark\bin\Release\JsonBenchmark.exe";

		static void Main(string[] args)
		{
			if (args.Length > 0) BenchExe = args[0];
			if (!File.Exists(BenchExe))
			{
				if (args.Length > 0 || !File.Exists("JsonBenchmark.exe"))
				{
					Console.WriteLine("Unable to find benchmark exe file: " + BenchExe);
					return;
				}
				BenchExe = "JsonBenchmark.exe";
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
						smallEventsSerialization = smallSerialization.Events,
						smallValuesSerialization = smallSerialization.Values,
						smallAggregatesSerialization = smallSerialization.Aggregates,
						smallEventsBoth = smallBoth.Events,
						smallValuesBoth = smallBoth.Values,
						smallAggregatesBoth = smallBoth.Aggregates,
						standardEventsSerialization = standardSerialization.Events,
						standardAggregatesSerialization = standardSerialization.Aggregates,
						standardEventsBoth = standardBoth.Events,
						standardAggregatesBoth = standardBoth.Aggregates,
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
			public List<Result> Events = new List<Result>();
			public List<Result> Values = new List<Result>();
			public List<Result> Aggregates = new List<Result>();
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
				result.Events.Add(d.Extract(0));
				result.Values.Add(d.Extract(1));
				result.Aggregates.Add(d.Extract(2));
			}
			Console.WriteLine(" ... done");
			return result;
		}

		class StandardTest
		{
			public List<Result> Events = new List<Result>();
			public List<Result> Aggregates = new List<Result>();
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
				result.Events.Add(d.Extract(0));
				result.Aggregates.Add(d.Extract(1));
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
			var passNJ = RunSinglePass("JsonNet", type, both, count);
			var passJil = RunSinglePass("Jil", type, both, count);
			var passRJ = RunSinglePass("RevenjJson", type, both, count);
			var passSS = RunSinglePass("ServiceStack", type, both, count);
			var passRP = RunSinglePass("RevenjProtoBuf", type, both, count);
			return new AggregatePass { JsonNet = passNJ, Jil = passJil, RevenjJson = passRJ, ServiceStack = passSS, RevenjProtobuf = passRP };
		}

		static List<Stats> RunSinglePass(string serializer, string type, bool both, int count)
		{
			var info = new ProcessStartInfo(BenchExe, serializer + " " + type + (both ? " Both " : " Serialization ") + count)
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
				result.Add(new Stats { Duration = -1, Errors = -1, Size = -1 });
				result.Add(new Stats { Duration = -1, Errors = -1, Size = -1 });
				result.Add(new Stats { Duration = -1, Errors = -1, Size = -1 });
				return result;
			}
			var lines = process.StandardOutput.ReadToEnd().Split('\n');
			for (int i = 0; i < lines.Length / 3; i++)
			{
				var duration = lines[i * 3].Split('=');
				var size = lines[i * 3 + 1].Split('=');
				var errors = lines[i * 3 + 2].Split('=');
				result.Add(new Stats { Duration = int.Parse(duration[1]), Size = int.Parse(size[1]), Errors = int.Parse(errors[1]) });
			}
			return result;
		}
	}

	struct Stats
	{
		public int Duration;
		public int Size;
		public int Errors;
	}

	class AggregatePass
	{
		public List<Stats> JsonNet;
		public List<Stats> Jil;
		public List<Stats> RevenjJson;
		public List<Stats> ServiceStack;
		public List<Stats> RevenjProtobuf;

		public Result Extract(int index)
		{
			return new Result
			{
				NewtonsoftJson = JsonNet[index],
				Jil = Jil[index],
				RevenjJson = RevenjJson[index],
				ServiceStack = ServiceStack[index],
				RevenjProtobuf = RevenjProtobuf[index],
			};
		}
	}

	class Result
	{
		public Stats NewtonsoftJson;
		public Stats Jil;
		public Stats RevenjJson;
		public Stats ServiceStack;
		public Stats RevenjProtobuf;
	}
}
