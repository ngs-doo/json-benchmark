##How fast are .NET Json serializers?

In yet another benchmark, we will put up popular Newtonsoft.Json against Stackoverflow's Jil and DSL Platform baked in serialization.
We'll be testing variety of models, from small simple objects, to very complex large objects.

###Models

 * [small](Benchmark/SmallObjects.dsl)
 * [standard](Benchmark/StandardObjects.dsl)
 * [large](Benchmark/LargeObjects.dsl)
 
###Testing assumptions

 * from stream and to stream - we want to avoid LOH issues, so no string/byte[] examples
 * simple model - tests actual serialization infrastructure since there is little serialization to do
 * standard model - non-trivial document model
 * large model - big documents - tests are bound by non-infrastructure parts, such as DateTime parsing, base64 conversion, etc...
 * almost default parameters - large model contains "advanced" features, such as interface serialization, which causes slightly modifications to Newtonsoft.Json configuration
 * one test at a time - perform one test and exit

###Libraries

 * Newtonsoft.Json 5.0.6 - most popular Nuget package. Very good library (only one bug detected and fixed) with excellent performance
 * Jil 2.1.1 - new kid on the block. Uses variety of optimizations during serialization
 * manual serialization code - DSL Platform bakes in serialization directly into the model. Doesn't contain much optimizations, but is very performant
 * Revenj.Json - default Revenj Json serialization which uses Newtonsoft.Json library
 * Revenj.Protobuf - default Revenj Protobuf serialization which uses modified Protobuf-net library (various bugfixes and changes - to support dynamic serialization)

*While Revenj 1.0.2 is used, latest version of Revenj.Serialization is used, since major performance byte[] conversion issue was detected.*
 
###Startup times

It's known issue that serialization libraries suffer from startup time, since they need to build and cache parsers for types.
Let's see how much of an issue is that:

    Small 1

![Startup times](results/startup-times.png)

As expected manual serialization has minimal startup time, since it was amortized at compile time. Since this cost can be nullified during system startup it's not really a big issue.

###Small model

Most libraries optimize for small Json payload, both with data structures used and with algorithms. These tests are usually infrastructure bound.

    Small 100.000

![Small objects](results/small-objects.png)

We can see Jil doing really well for small simple messages. Newtonsoft.Json struggles with deserialization in this test.

###Non-trivial model

Non-trivial model should reflect most CRUD scenarios with documents. In this example it contains several data types, fields, collections, but nothing fancy (like polymorphism or strange data types).

    Standard 10.000

![Non-trivial objects](results/non-trivial-objects.png)

It seems Jil fails at serialization in this test. Newtonsoft again is lagging on deserialization.

###Large model

Sometimes big payload is exchanged over the wire. This example should be mostly .NET Framework bound, although it's interesting to see how each library copes with LOH issues. Also, simple polymorphism is utilized just to check if library supports such scenario. Strange data types were left out of the test, since most libraries don't support it out of the box.

    Large 100

![Large objects](results/large-objects.png)

In this test Jil fails at deserialization. Newtonsoft is coping really well against the manual serialization, but at the cost of the memory fragmentation.

###Full results

Results are available in [Excel file](results/results.xlsx).


###Reproducing results

It's non-trivial to reproduce this tests, since Revenj is not optimized for standalone testing. 

Easiest way to reproduce it is to:

 * download [setup](releases/tag/1.0.0/setup.zip) and unpack it
 * apply *Migration.sql* script to a Postgres database
 * change ConnectionString key in [JsonBenchmark.exe.config](Benchmark/App.config) to point to the Postgres database
 * run *GatherResults.exe* or (*GatherResults.exe JsonBenchmark.exe 5*)

More complicated way to reproduce it is to:

 * install Visual studio plugin: [DDD for DSL](https://visualstudiogallery.msdn.microsoft.com/5b8a140c-5c84-40fc-a551-b255ba7676f4)
 * register at [DSL Platform](https://dsl-platform.com) to be able to compile DSL models
 * login to plugin and change [connection string](Benchmark/JsonBenchmark.sln)
 * download Revenj core (v1.0.2) from plugin configuration options
 * use [latest Revenj serialization](Benchmark/Revenj/Revenj.Serialization.dll) instead of default version (to fix byte[] performance issue)
 * upgrade database and recreate [ServerModel.dll](Benchmark/lib/ServerModel.dll) from DSLs
 * run [GatherResults solution](GatherResults/GatherResults.sln) to run the analysis


 