#!/bin/bash

set -exuo pipefail

export DISABLE_AUTOBREW=1

# ${R_ARGS} necessary to support cross-compilation
export PATH=$PATH:$JAVA_HOME/bin

autoreconf --install
autoconf
pushd jri
  autoconf
popd
${R} CMD INSTALL --build . ${R_ARGS:-}
