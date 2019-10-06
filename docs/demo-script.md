# End to end Quarkus demo

This is a basic demo that shows how to build a Quarkus app that exposes a CRUD interface through a RESTFul API. We'll start developing locally to later move to Openshift Code Ready Workspace (web IDE) to continue there.

# Preparation

A Quarkus app is a Java app tailored for GraaVM and Hotspot which provides some interesting benefits: amazingly fast boot time, incredibly low RSS memory (not just heap size!) which redunds in offering near instant scale up and high density memory utilization in container orchestration platforms like Kubernetes.

There are several ways you can run a Quarkus app:

* As a java app on JVM
* As a native app locally
* As a native app in a container


Our demo exposes a simple CRUD interface to a table of fruits in PostgreSQL, so let's create a PostgreSQL DB in our cluster.

## Create a folder for our new project

```sh
mkdir -p ~/quarkus-demo/atomic-fruit-service
```

## Installing GraalVM

```sh

curl -OL https://github.com/oracle/graal/releases/download/vm-19.1.1/graalvm-ce-darwin-amd64-19.1.1.tar.gz
tar xvzf graalvm-ce-darwin-amd64-19.1.1.tar.gz
```

## Log in to your cluster

```sh
oc login ...
```

## Let's create a project for our app

```sh

```

# Local to Cloud development loop

Syncing files to our CRW workspace from our local folder

```sh
./sync-workspace.sh
```


