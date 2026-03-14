FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /workspace

COPY gradle gradle
COPY gradlew build.gradle settings.gradle ./
COPY src src

RUN ./gradlew bootJar --no-daemon
RUN mkdir -p build/dependency && cd build/dependency && jar -xf ../libs/*.jar

FROM eclipse-temurin:21-jre-alpine

ENV CONFIG_FOLDER=/config

COPY --from=build /workspace/build/dependency/BOOT-INF/lib /app/lib
COPY --from=build /workspace/build/dependency/META-INF /app/META-INF
COPY --from=build /workspace/build/dependency/BOOT-INF/classes /app

ENTRYPOINT ["java", "-cp", "app:app/lib/*", "org.example.Main"]