#!/bin/bash

# All this (and it is fairly brittle) just to get the
# value for JAVA_LD_LIBRARY_PATH as determined by:
# R CMD javareconf
echo 'echo $JAVA_LD_LIBRARY_PATH' > $PWD/java_reconf
chmod +x $PWD/java_reconf
JAVA_LD_LIBRARY_PATH=$($R CMD javareconf -e $PWD/java_reconf | tail -n1)
echo "JAVA_LD_LIBRARY_PATH as determined by R CMD javareconf: $JAVA_LD_LIBRARY_PATH"

# Now re-configure to set the correct values.
$R CMD javareconf

if [[ "$(uname)" == "Linux" ]]; then
  export LD_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
elif [[ "$(uname)" == "Darwin" ]]; then
  export DYLD_FALLBACK_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${DYLD_FALLBACK_LIBRARY_PATH}
fi

$R CMD INSTALL --build .
