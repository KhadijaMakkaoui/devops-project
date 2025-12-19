# Stage 1: Build the Spring Boot application
FROM maven:3.8.1-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Runtime image
FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar product-service.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "product-service.jar"]
