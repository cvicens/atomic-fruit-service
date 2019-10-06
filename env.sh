#!/bin/sh

GRAALVM_VERSION="19.2.0.1"
GRAALVM_HOME=$(pwd)/graalvm-ce-${GRAALVM_VERSION}

if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    GRAALVM_HOME=${GRAALVM_HOME}/Contents/Home
fi

export GRAALVM_VERSION, GRAALVM_HOME

export PATH=${GRAALVM_HOME}/bin:$PATH