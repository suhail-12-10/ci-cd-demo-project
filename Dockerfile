FROM openjdk:11
WORKDIR /app
COPY target/demo-1.0.0.jar app.jar
EXPOSE 9090
ENTRYPOINT ["java", "-jar", "app.jar", "--server.port=9090"]
