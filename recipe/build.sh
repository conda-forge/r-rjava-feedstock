#!/bin/bash

export DISABLE_AUTOBREW=1

# ${R_ARGS} necessary to support cross-compilation
${R} CMD INSTALL --build . ${R_ARGS}
