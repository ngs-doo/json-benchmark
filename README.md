##.NET vs JVM Json serialization

In yet another benchmark, we will put up most popular .NET library - Newtonsoft.Json against most popular (fastest?) JVM library - Jackson and DSL Platform baked in serialization (both with all properties serialized and only properties with non-default values).

We'll be testing variety of models, from small simple objects, to very complex large objects; with different number of loops.

Originaly more libraries were tested, but since they don't support advanced features and some even fail to serialize simple objects (due to need for reflection) they were removed.

###Models

 * [small](Benchmark/SmallObjects.dsl)
 * [standard](Benchmark/StandardObjects.dsl)
 * [large](Benchmark/LargeObjects.dsl)
 
###Testing assumptions

 * .NET: from stream and to stream - we want to avoid LOH issues, so no byte[] examples (even if it could be used on small objects) - while we could use byte[] pool just for serialization, this bench doesn't currently test for that
 * JVM: from byte[] to byte[] - .NET reuses same stream instance, JVM baked in serialization always create a new byte[] when converting String -> byte[] and Jackson uses it's own optimizations and specialized streams to handle such scenario
 * simple model - tests actual serialization infrastructure since there is little serialization to do
 * standard model - non-trivial document model
 * large model - big documents - tests should be bound by non-infrastructure parts, such as DateTime parsing, base64 conversion, etc...
 * almost default parameters - large model contains "advanced" features, such as interface serialization, which causes slightly modifications to Newtonsoft.Json configuration, still it uses default enum representation as number, which is one of the difference during serialization (no native Date type in .NET - although baked in serialization writes it in native date format)
 * one test at a time - perform one test and exit - while this will nullify JVM optimizations in runtime, they should show up in tests with larger number of loops.
 * Protocol buffers are here just to provide baseline
 * track duration of creating new object instance

###Libraries

 * Newtonsoft.Json 6.0.6 - most popular Nuget package
 * Revenj.Json (1.1.2) (baked in serialization code) - DSL Platform bakes in serialization directly into the model. Revenj Json converters are used for serialization and deserialization 
 * Protobuf.NET (Revenj 1.1.2) - default Revenj Protobuf serialization which uses modified Protobuf-net library (various bugfixes and changes - to support dynamic serialization)
 * Jackson 2.4.1 - most popular JVM Json serializer
 * DSL client Java (1.1.0) - DSL Platform baked in serialization into Java classes
 
###Startup times

It's known issue that serialization libraries suffer from startup time, since they need to build and cache parsers for types.
Let's see how much of an issue is that:

    Small 1 (Message)

![Startup times](results/startup-times.png)

As expected manual serialization has minimal startup time, since it was amortized at compile time. While this can be nullified on servers with longer startup, it's not really a big issue but it can cause noticable delays on mobile apps. It's interesting to see JVM baked in minimal serialization taking 0 ms due to avoidance of serializing anything except {}

###Small model

Most libraries optimize for small Json payload, both with data structures and algorithms. These tests are usually infrastructure bound.

    Small 1.000.000 (Message)

![Small objects duration](results/small-objects.png)

Since there is large number of loops JVM optimizations kicks-in so it's interesting to compare it to both smaller number of loops (100k) and larger number of loops (10M). .NET shows a strange difference in deserialization time (it seems that larger payloads are deserialized more quickly with the same code in baked in deserialization). *This requires more investigation in whats going on.*

###Non-trivial model

Non-trivial model should reflect most CRUD scenarios with documents. This example uses only several data types but it shows very interesting difference between .NET and JVM.

    Standard 10.000/1.000.000 (DeletePost)

![Non-trivial objects duration](results/non-trivial-objects.png)

While .NET it's much faster before JVM optimizations kick-in, JVM serialization seems to be 2x faster after . Same optimizations could not be used for serialization in baked in libraries due to different APIs on .NET Framework and Java. 

###Large model

Large model contains serveral advanced features, such as interface serialization, occasional byte[] serialization and deep nested objects. Strange data types were left out of the test, since most libraries don't support it out of the box.

    Large 1.000 (LargeObject.Book)

![Large objects duration](results/large-objects.png)

Results seem to be consistent regardless of the number of loops. .NET takes much more time to construct object instances.

###Full results

Results are available in [Excel file](results/results.xlsx).

JVM: 1.7.21 and .NET: 4.5.1

###Reproducing results

Easiest way to reproduce results is to:

 * apply [sql scripts](SQL) to a Postgres database
 * change ConnectionString key in [JsonBenchmark.exe.config](app/JsonBenchmark.exe.config) to point to the Postgres database
 * run *[GatherResults.exe](app/GatherResults.exe)* or (*GatherResults.exe . 5*)

If you are interested in changing the models, then you can:

 * install Visual studio plugin: [DDD for DSL](https://visualstudiogallery.msdn.microsoft.com/5b8a140c-5c84-40fc-a551-b255ba7676f4)
 * or use [dsl-clc.jar with compile.bat](Benchmark/compile.bat)
 * register at [DSL Platform](https://dsl-platform.com) to be able to compile DSL models
 * upgrade database and recreate [ServerModel.dll](Benchmark/lib/ServerModel.dll) from DSLs
 * run [GatherResults solution](GatherResults/GatherResults.sln) to run the analysis

###Conclusions

* JVM seems to be always faster after optimizations kick-in.
* Newtonsoft.Json is comparable with Jackson on features, but not in speed on some use-cases.
* Baked in serialization is not nearly mature as those two libraries (since it was written in 2 weeks), so various optimizations could be built in.
* Excluding default parameters from JSON doesn't really show up as winner in this tests, since they are rarely excluded - it would be interesting to see comparison with a more sparse objects.