@echo off
cd "%~dp0"

java -jar dsl-clc.jar -java_client=lib\generated-model.jar -dependencies:java_client=dependencies\java_client -dsl=. -namespace=hr.ngs.benchmark -manual-json -compiler

call mvn deploy:deploy-file -Durl=file://lib -Dfile=lib/generated-model.jar -DgroupId=hr.ngs.benchmark -DartifactId=generated-model -Dpackaging=jar -Dversion=1.0.0-SNAPSHOT