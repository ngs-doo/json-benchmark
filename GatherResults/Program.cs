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
			var largeBoth = RunLarge(true, repeat);
			var startupSerialization = RunStartup(false, repeat);
			var startupBoth = RunStartup(true, repeat);
			var smallSerialization = RunSmall(false, repeat);
			var smallBoth = RunSmall(true, repeat);
			var standardSerialization = RunStandard(false, repeat);
			var standardBoth = RunStandard(true, repeat);
			var largeSerialization = RunLarge(false, repeat);
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
				var d = GetherDuration("Small", both, 1);
				Console.Write("...");
				Console.Write(i + 1);
				result.Add(
					new Result
					{
						NewtonsoftJson = d.JsonNet[0].Duration,
						Jil = d.Jil[0].Duration,
						Manual = d.Manual[0].Duration,
						RevenjJson = d.RevenjJson[0].Duration,
						RevenjProtobuf = d.RevenjProtobuf[0].Duration
					});
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
				result.Events.Add(new Result
				{
					NewtonsoftJson = d.JsonNet[0].Duration,
					Jil = d.Jil[0].Duration,
					Manual = d.Manual[0].Duration,
					RevenjJson = d.RevenjJson[0].Duration,
					RevenjProtobuf = d.RevenjProtobuf[0].Duration
				});
				result.Values.Add(new Result
				{
					NewtonsoftJson = d.JsonNet[1].Duration,
					Jil = d.Jil[1].Duration,
					Manual = d.Manual[1].Duration,
					RevenjJson = d.RevenjJson[1].Duration,
					RevenjProtobuf = d.RevenjProtobuf[1].Duration
				});
				result.Aggregates.Add(new Result
				{
					NewtonsoftJson = d.JsonNet[2].Duration,
					Jil = d.Jil[2].Duration,
					Manual = d.Manual[2].Duration,
					RevenjJson = d.RevenjJson[2].Duration,
					RevenjProtobuf = d.RevenjProtobuf[2].Duration
				});
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
				result.Events.Add(new Result
				{
					NewtonsoftJson = d.JsonNet[0].Duration,
					Jil = d.Jil[0].Duration,
					Manual = d.Manual[0].Duration,
					RevenjJson = d.RevenjJson[0].Duration,
					RevenjProtobuf = d.RevenjProtobuf[0].Duration
				});
				result.Aggregates.Add(new Result
				{
					NewtonsoftJson = d.JsonNet[1].Duration,
					Jil = d.Jil[1].Duration,
					Manual = d.Manual[1].Duration,
					RevenjJson = d.RevenjJson[1].Duration,
					RevenjProtobuf = d.RevenjProtobuf[1].Duration
				});
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
				var d = GetherDuration("Large", both, 100);
				Console.Write("...");
				Console.Write(i + 1);
				result.Add(new Result
				{
					NewtonsoftJson = d.JsonNet[0].Duration,
					Jil = d.Jil[0].Duration,
					Manual = d.Manual[0].Duration,
					RevenjJson = d.RevenjJson[0].Duration,
					RevenjProtobuf = d.RevenjProtobuf[0].Duration
				});
			}
			Console.WriteLine(" ... done");
			return result;
		}

		static AggregatePass GetherDuration(string type, bool both, int count)
		{
			var passNJ = RunSinglePass("JsonNet", type, both, count);
			var passJil = RunSinglePass("Jil", type, both, count);
			var passRM = RunSinglePass("RevenjManual", type, both, count);
			var passRJ = RunSinglePass("RevenjJsonNet", type, both, count);
			var passRP = RunSinglePass("RevenjProtoBuf", type, both, count);
			return new AggregatePass { JsonNet = passNJ, Jil = passJil, Manual = passRM, RevenjJson = passRJ, RevenjProtobuf = passRP };
		}

		static List<SinglePass> RunSinglePass(string serializer, string type, bool both, int count)
		{
			var info = new ProcessStartInfo(BenchExe, serializer + " " + type + (both ? " Both " : " Serialization ") + count)
			{
				UseShellExecute = false,
				RedirectStandardOutput = true,
				RedirectStandardError = true,
				CreateNoWindow = true
			};
			var result = new List<SinglePass>();
			var process = Process.Start(info);
			process.WaitForExit();
			if (process.ExitCode != 0)
			{
				Console.WriteLine();
				var error = process.StandardError.ReadToEnd();
				process.Close();
				Console.WriteLine(error);
				result.Add(new SinglePass { Duration = -1, Errors = -1, Size = -1, Error = error });
				result.Add(new SinglePass { Duration = -1, Errors = -1, Size = -1, Error = error });
				result.Add(new SinglePass { Duration = -1, Errors = -1, Size = -1, Error = error });
				return result;
			}
			var lines = process.StandardOutput.ReadToEnd().Split('\n');
			for (int i = 0; i < lines.Length / 3; i++)
			{
				var duration = lines[i * 3].Split('=');
				var size = lines[i * 3 + 1].Split('=');
				var errors = lines[i * 3 + 2].Split('=');
				result.Add(new SinglePass { Duration = int.Parse(duration[1]), Size = int.Parse(size[1]), Errors = int.Parse(errors[1]) });
			}
			return result;
		}
	}

	struct Result
	{
		public int NewtonsoftJson;
		public int Jil;
		public int Manual;
		public int RevenjJson;
		public int RevenjProtobuf;
	}

	struct SinglePass
	{
		public int Duration;
		public int Size;
		public int Errors;
		public string Error;
	}

	class AggregatePass
	{
		public List<SinglePass> JsonNet;
		public List<SinglePass> Jil;
		public List<SinglePass> Manual;
		public List<SinglePass> RevenjJson;
		public List<SinglePass> RevenjProtobuf;
	}
}
