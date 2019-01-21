#!/bin/bash
export LD_LIBRARY_PATH=${PREFIX}/jre/lib/amd64/server/
$R CMD INSTALL --build .
