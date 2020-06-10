#!/bin/sh

export PROJECT_NAME="atomic-fruit"
export APP_NAME="fruits-app"

export QUARKUS_VERSION="1.5.0.Final"

export GRAALVM_VERSION="19.3.1"
GRAALVM_HOME=$(pwd)/graalvm-ce-java11-${GRAALVM_VERSION}
if [[ "$OSTYPE" == "darwin"* ]]; then GRAALVM_HOME=${GRAALVM_HOME}/Contents/Home ; fi
export GRAALVM_HOME
export PATH=${GRAALVM_HOME}/bin:$PATH

if [[ "$OSTYPE" == "linux"* ]]; then GRAALVM_OSTYPE=linux ; fi
if [[ "$OSTYPE" == "darwin"* ]]; then GRAALVM_OSTYPE=darwin ; fi
export GRAALVM_OSTYPE

export KNATIVE_CLI_VERSION="0.14.0"
if [[ "$OSTYPE" == "linux"* ]]; then KNATIVE_OSTYPE=Linux ; fi
if [[ "$OSTYPE" == "darwin"* ]]; then KNATIVE_OSTYPE=Darwin ; fi
export KNATIVE_OSTYPE

export TEKTON_CLI_VERSION="0.9.0"
if [[ "$OSTYPE" == "linux"* ]]; then TEKTON_OSTYPE=Linux ; fi
if [[ "$OSTYPE" == "darwin"* ]]; then TEKTON_OSTYPE=Darwin ; fi
export TEKTON_OSTYPE

mkdir -p ./bin
export PATH=$(pwd)/bin:$PATH