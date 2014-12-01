@echo off
cd "%~dp0"

call mvn clean compile package

if exist target\json-benchmark-1.0.0-SNAPSHOT-jar-with-dependencies.jar (
  copy target\json-benchmark-1.0.0-SNAPSHOT-jar-with-dependencies.jar ..\app\json-benchmark.jar
)
