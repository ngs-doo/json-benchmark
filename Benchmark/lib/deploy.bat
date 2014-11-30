call mvn deploy:deploy-file -Durl=file://. -Dfile=generated-model.jar -DgroupId=hr.ngs.benchmark -DartifactId=generated-model -Dpackaging=jar -Dversion=1.0.0
call mvn deploy:deploy-file -Durl=file://. -Dfile=dsl-client-java-1.0.5.jar -DgroupId=com.dslplatform -DartifactId=dsl-client-java -Dpackaging=jar -Dversion=1.0.5
