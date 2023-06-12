#!/bin/bash

export DISABLE_AUTOBREW=1

# ${R_ARGS} necessary to support cross-compilation
export PATH=$PATH:$JAVA_HOME/bin
${R} CMD javareconf
${R} CMD INSTALL --build . ${R_ARGS}
