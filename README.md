# Atomic Fruit Service

This is sample service generated from a maven artifact with the next command.

```sh
mvn io.quarkus:quarkus-maven-plugin:$QUARKUS_VERSION:create \
  -DprojectGroupId="com.redhat.atomic.fruit" \
  -DprojectArtifactId="atomic-fruit-app" \
  -DprojectVersion="1.0-SNAPSHOT" \
  -DclassName="FruitResource" \
  -Dpath="fruit"
```

# Prerequisites

> **NOTE:** Change to the cloned folder.

## Download GraalVM

```sh
curl -OL https://github.com/oracle/graal/releases/download/vm-19.1.1/graalvm-ce-darwin-amd64-19.1.1.tar.gz
tar xvzf graalvm-ce-darwin-amd64-19.1.1.tar.gz
```

## Set environment

Sets GraalVM home.

```sh
. ./env.sh
```

## Install native image for GraalVM

```sh
gu install native-image
```

## Login to your Openshift cluster

```sh
oc login ...
```

## Create a project or use an already existing one

```sh
oc new-project atomic-fruit
```

# Testing different ways of packaging the app

> You must be inside the project folder to run the following commands.

## JVM mode

This mode generates a Quarkus Java jar file.

```sh
./mvnw -DskipTests clean package
```

Run the application in JVM mode.

```sh
java -jar ./target/atomic-fruit-service-1.0-SNAPSHOT-runner.jar
```

## Native Mode

This mode generates a Quarkus native binary file.

```sh
./mvnw -DskipTests clean package -Pnative
```

Run the application in native mode.

```sh
./target/atomic-fruit-service-1.0-SNAPSHOT-runner
```

## Docker-Native Mode

This mode generates a Quarkus native binary file using an image and builds an image with it.

```sh
./mvnw package -DskipTests -Pnative -Dnative-image.docker-build=true
docker build -f src/main/docker/Dockerfile.native -t atomic-fruit-service:1.0-SNAPSHOT .
```

Run the image created.

```sh
docker run -it --rm -p 8080:8080 atomic-fruit-service:1.0-SNAPSHOT
```

Push it to the image registry of your choice.

```sh
docker tag atomic-fruit-service:1.0-SNAPSHOT quay.io/<quay_user>/atomic-fruit-service:1.0-SNAPSHOT
docker push quay.io/<quay_user>/atomic-fruit-service:1.0-SNAPSHOT
```

# Configuring log

Configuring Logging
You can configure Quarkus logging by setting the following parameters to $PROJECT_HOME/src/main/resources/application.properties:

```properties
quarkus.log.console.enable=true
quarkus.log.console.level=DEBUG
```

# Run in development mode 

```sh
./mvnw compile quarkus:dev
```

# Adding custom properties

Add the following to the class you want to use your custom property.

```java
...
import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/fruit")
public class FruitResource {

    @ConfigProperty(name = "greetings.message")
    String message;
    ...
```

Add the following property to your application.properties.

```properties
# custom properties
greetings.message = hello
```

# Adding PostgreSQL

## Deploy PostgreSQL

We're going to deploy PostgreSQL using a template, in general an operator is a better choice but for the sake of simplicity in this demo a template is a good choice.

```sh
oc new-app -n atomic-fruit -p DATABASE_SERVICE_NAME=my-database -p POSTGRESQL_USER=luke -p POSTGRESQL_PASSWORD=secret -p POSTGRESQL_DATABASE=my_data -p POSTGRESQL_VERSION=10 postgresql-persistent
```

## Adding DB related extensions

We need some eextensions to expose our database to the world: REST JSON, PostgreSQL and Hibernate as our ORM.

```sh
./mvnw quarkus:add-extension -Dextension="quarkus-resteasy-jsonb, quarkus-jdbc-postgresql, quarkus-hibernate-orm-panache"
```

## Edit the application.properties

Add the following properties to your `./src/main/resources/application.properties` file:

```properties
# configure your datasource
quarkus.datasource.url = jdbc:postgresql://my-database:5432/my_data
%dev.quarkus.datasource.url = jdbc:postgresql://127.0.0.1:5432/my_data
quarkus.datasource.driver = org.postgresql.Driver
quarkus.hibernate-orm.dialect = org.hibernate.dialect.PostgreSQL95Dialect
quarkus.datasource.username = luke
quarkus.datasource.password = secret


# drop and create the database at startup (use `update` to only update the schema)
quarkus.hibernate-orm.database.generation = drop-and-create
# show sql statements in log
quarkus.hibernate-orm.log.sql = true
```

## Testing locally using port-forwarding

In a different terminal...

```sh
oc -n atomic-fruit port-forward svc/my-database 5432
```

In your current terminal run your code using profile `dev`

```sh
./mvnw compile quarkus:dev
```

# Adding Swagger UI

```sh
./mvnw quarkus:add-extension -Dextensions="openapi"
```

## Test creating a fruit

```sh
curl -vvv -d '{"name": "banana", "season": "summer"}' -H "Content-Type: application/json" POST http://localhost:8080/fruit
* Rebuilt URL to: POST/
* Could not resolve host: POST
* Closing connection 0
curl: (6) Could not resolve host: POST
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8080 (#1)
> POST /fruit HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.54.0
> Accept: */*
> Content-Type: application/json
> Content-Length: 38
> 
* upload completely sent off: 38 out of 38 bytes
< HTTP/1.1 201 Created
< Location: http://localhost:8080/fruit/1
< Content-Length: 0
< 
* Connection #1 to host localhost left intact
```

# Testing using the Swagger UI

Create a 