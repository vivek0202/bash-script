#!/bin/bash

# Check if JAVA_HOME is set
if [ -z "$JAVA_HOME" ]; then
    echo "Error: JAVA_HOME is not set"
    exit 1
fi

# Compile the Java program
echo "Compiling WebLogicSSLTest.java..."
$JAVA_HOME/bin/javac WebLogicSSLTest.java

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# Run the program with the provided URL
if [ -z "$1" ]; then
    echo "Usage: ./run-weblogic-test.sh <weblogic-url>"
    echo "Example: ./run-weblogic-test.sh https://weblogic-server:7002"
    exit 1
fi

echo "Running WebLogic SSL test..."
$JAVA_HOME/bin/java WebLogicSSLTest "$1"
