# Atomic Fruit Service

This is sample service generated from a maven artifact with the next command.

```sh
mvn io.quarkus:quarkus-maven-plugin:$QUARKUS_VERSION:create \
  -DprojectGroupId="com.redhat.atomic.fruit" \
  -DprojectArtifactId="atomic-fruit-service" \
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

## Testing using the Swagger UI

Try to create a new fruit, get all and get by season.

> **WARNING:** Don't forget to delete the `id` property when creating a new fruit because `id` is self-generated.


## Building an image locally using S2I

```
$ s2i build https://github.com/cvicens/atomic-fruit-service quay.io/quarkus/ubi-quarkus-native-s2i:19.1.1 --context-dir=. atomic-fruit-service
```

```
$ docker logs $(docker ps | grep quay.io/quarkus/ubi-quarkus-native-s2i:19.1.1 | awk -F ' ' '{print $1}')
$ docker images | grep atomic-fruit-service
$ docker inspect --format='{{ index .Config.Labels "io.openshift.s2i.scripts-url" }}' quay.io/quarkus/ubi-quarkus-native-s2i:19.1.1
$ docker run -it --rm -p 8080 atomic-fruit-service /bin/bash

```

## Building using S2I on Openshift

```sh
oc new-app quay.io/quarkus/ubi-quarkus-native-s2i:19.1.1~https://github.com/cvicens/atomic-fruit-service --context-dir=. --name=atomic-fruit-service-native -n atomic-fruit
```

> You may need to add resources to the BuildConfig

```
spec:
  resources:
    limits:
      cpu: "1500m" 
      memory: "5Gi"
```

# Tekton Pipeline

> Ref: https://github.com/openshift/pipelines-tutorial

## Preprequisites

### Install OpenShift Pipelines

https://github.com/openshift/pipelines-tutorial/blob/master/install-operator.md

### Adjusting security configuration

Building container images using build tools such as S2I, Buildah, Kaniko, etc require privileged access to the cluster. OpenShift default security settings do not allow privileged containers unless specifically configured. Create a service account for running pipelines and enable it to run privileged pods for building images:

```sh
$ oc create serviceaccount pipeline
$ oc adm policy add-scc-to-user privileged -z pipeline
$ oc adm policy add-role-to-user edit -z pipeline
```

## Create tasks

```sh
oc apply -f ./src/main/k8s/openshift-client-task.yaml -n atomic-fruit
oc apply -f ./src/main/k8s/s2i-quarkus-task.yaml -n atomic-fruit
```
Check that our tasks are there.

```sh
tkn tasks list
NAME               AGE
openshift-client   35 minutes ago
s2i-quarkus        6 minutes ago
```

## Create a pipeline with those tasks

Create a pipeline by running the next command.

```sh
oc apply -f ./src/main/k8s/atomic-fruit-service-build-pipeline.yaml -n atomic-fruit
oc apply -f ./src/main/k8s/atomic-fruit-service-deploy-pipeline.yaml -n atomic-fruit
```

Let's see if our pipeline is where it should be.

```sh
 tkn pipeline list
NAME                                   AGE              LAST RUN                                         STARTED        DURATION     STATUS
atomic-fruit-service-build-pipeline    11 seconds ago   ---                                              ---            ---          ---
atomic-fruit-service-deploy-pipeline   1 day ago        atomic-fruit-service-deploy-pipeline-run-bd2hd   23 hours ago   9 minutes    Succeeded
```

## Triggering a pipeline

Triggering pipelines is an area that is under development and in the next release it will be possible to be done via the OpenShift web console and Tekton CLI. In this tutorial, you will trigger the pipeline through creating the Kubernetes objects (the hard way!) in order to learn the mechanics of triggering.

First, you should create a number of PipelineResources that contain the specifics of the Git repository and image registry to be used in the pipeline during execution. Expectedly, these are also reusable across multiple pipelines.

```sh
oc apply -f ./src/main/k8s/atomic-fruit-service-resources.yaml -n atomic-fruit
```
List those resources we've just created.

```sh
$ tkn resources list
NAME                         TYPE    DETAILS
atomic-fruit-service-git     git     url: https://github.com/cvicens/atomic-fruit-service
atomic-fruit-service-image   image   url: image-registry.openshift-image-registry.svc:5000/atomic-fruit/atomic-fruit-service
```

Now it's time to actually trigger the pipeline.

> **NOTE 1:** you may need to delete or tune limit in your namespace as in `oc delete limitrange --all -n atomic-fruit`
> **NOTE 2:** The `-r` flag specifies the PipelineResources that should be provided to the pipeline and the `-s` flag specifies the service account to be used for running the pipeline finally `-p` is for parameters.


Let's trigger a quarkus native build

```sh
$ tkn pipeline start atomic-fruit-service-build-pipeline \
        -r app-git=atomic-fruit-service-git \
        -r app-image=atomic-fruit-service-image \
        -p APP_NAME=atomic-fruit-service \
        -p NAMESPACE=atomic-fruit \
        -s pipeline


```

Now let's deploy our app as a normal DeployConfig.

```sh
$ tkn pipeline start atomic-fruit-service-deploy-pipeline \
        -r app-git=atomic-fruit-service-git \
        -r app-image=atomic-fruit-service-image \
        -p APP_NAME=atomic-fruit-service \
        -p NAMESPACE=atomic-fruit \
        -s pipeline

Pipelinerun started: atomic-fruit-service-deploy-pipeline-run-xdtvs

In order to track the pipelinerun progress run:
tkn pipelinerun logs atomic-fruit-service-deploy-pipeline-run-xdtvs -f -n atomic-fruit
```

