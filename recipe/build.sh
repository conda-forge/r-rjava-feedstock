#!/bin/bash

# All this (and it is fairly brittle) just to get the
# value for JAVA_LD_LIBRARY_PATH as determined by:
# R CMD javareconf
# Find Java in the compiler's sysroot
if [[ ${HOST} =~ .*linux.* ]]; then
  export JAVAC=$(find ${PREFIX}/${HOST}/sysroot -path "*/bin/javac")
  export JAVAH=$(find ${PREFIX}/${HOST}/sysroot -path "*/bin/javah")
  export JAVA=${JAVAC: : -1}
  export JAR=$(find ${PREFIX}/${HOST}/sysroot -path "*/bin/jar")
  # export JAVA_HOME=$(dirname $(dirname ${JAVA}))
fi
echo 'echo $JAVA_LD_LIBRARY_PATH' > $PWD/java_reconf
chmod +x $PWD/java_reconf
JAVA_LD_LIBRARY_PATH=$($R CMD javareconf -e $PWD/java_reconf | tail -n1)
echo "JAVA_LD_LIBRARY_PATH as determined by R CMD javareconf: $JAVA_LD_LIBRARY_PATH"

# Now re-configure to set the correct values.
R CMD javareconf

if [[ $(uname) == Linux ]]; then
  export LD_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
elif [[ $(uname) == Darwin ]]; then
  export DYLD_FALLBACK_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${DYLD_FALLBACK_LIBRARY_PATH}
fi

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
