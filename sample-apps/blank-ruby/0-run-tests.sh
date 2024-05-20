#!/bin/bash
set -eo pipefail
if [ ! -d lib ]; then
  echo "Installing libraries..."
  ./2-build-layer.sh
fi
export GEM_PATH=lib/ruby/3.2.0
ruby function/lambda_function.test.rb
