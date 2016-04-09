@echo off
cd "%~dp0"

java -jar dsl-clc.jar java_pojo=lib\generated-model.jar dsl=. namespace=hr.ngs.benchmark manual-json jackson java-beans joda-time download

call mvn deploy:deploy-file -Durl=file://lib -Dfile=lib/generated-model.jar -DgroupId=hr.ngs.benchmark -DartifactId=generated-model -Dpackaging=jar -Dversion=1.5