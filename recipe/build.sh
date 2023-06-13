#!/bin/bash

set -exuo pipefail

export DISABLE_AUTOBREW=1

# ${R_ARGS} necessary to support cross-compilation
export PATH=$PATH:$JAVA_HOME/bin
if [[ "${target_platform}" == linux-* ]]; then
  export LD_LIBRARY_PATH=${PREFIX}/lib/server/
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PREFIX/lib/jvm/lib/server
fi
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib/R/lib"

${R} CMD javareconf

autoreconf --install
autoconf
pushd jri
  autoconf
popd
${R} CMD INSTALL --build . ${R_ARGS:-}
