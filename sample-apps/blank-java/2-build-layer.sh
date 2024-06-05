#!/bin/bash
set -eo pipefail

gradle -q packageLibs
mv build/distributions/apm-bench-java.zip build/apm-bench-java-lib.zip

zip --junk-paths build/apm-bench-java-lib.zip ../swo-resources/collector-*.yaml