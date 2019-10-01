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

## Download GraalVM

```sh
curl -OL https://github.com/oracle/graal/releases/download/vm-19.1.1/graalvm-ce-darwin-amd64-19.1.1.tar.gz
tar xvzf graalvm-ce-darwin-amd64-19.1.1.tar.gz
```

# Set environment

Sets GraalVM home.

```sh
. ./env.sh
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
./target/fruits-app-1.0-SNAPSHOT-runner
```

# Adding MariaDB to the mix
