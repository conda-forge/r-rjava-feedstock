#!/bin/bash

if [[ "$(uname)" == "Linux" ]]; then
  export LD_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
elif [[ "$(uname)" == "Darwin" ]]; then
  export DYLD_FALLBACK_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${DYLD_FALLBACK_LIBRARY_PATH}
fi

$R CMD INSTALL --build .
