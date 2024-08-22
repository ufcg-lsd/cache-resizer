FROM openjdk:17-alpine as build

WORKDIR /app

COPY build.gradle settings.gradle gradlew ./
COPY gradle/ gradle/
COPY src/ src/

RUN chmod +x ./gradlew && \
    ./gradlew clean build --parallel -x test

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/build/libs/test-app.jar"]

FROM openjdk:17-alpine

WORKDIR /app

COPY --from=build /app/build/libs/*.jar test-app.jar

EXPOSE 8080

CMD ["java", "-jar", "test-app.jar"]