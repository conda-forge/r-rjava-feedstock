#!/bin/bash

# Find Java in the compiler's sysroot
if [[ ${HOST} =~ .*linux.* ]]; then
  export JAVAC=$(find ${PREFIX}/${HOST}/sysroot -path "*/bin/javac")
  export JAVAH=$(find ${PREFIX}/${HOST}/sysroot -path "*/bin/javah")
  export JAVA=${JAVAC%?}
  export JAR=$(find ${PREFIX}/${HOST}/sysroot -path "*/bin/jar")
  # Hack so that sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.131.x86_64/jre/lib/amd64/libnio.so
  # finds sysroot/usr/lib{64}/libgconf-2.so.4 (horrible..)
  if [[ ${HOST} =~ i686.* ]]; then
    export LD_LIBRARY_PATH=${PREFIX}/lib:${PREFIX}/${HOST}/sysroot/usr/lib
  else
    export LD_LIBRARY_PATH=${PREFIX}/lib:${PREFIX}/${HOST}/sysroot/usr/lib64
  fi
fi

# All this (and it is fairly brittle) just to get the
# value for JAVA_LD_LIBRARY_PATH as determined by:
# R CMD javareconf
echo 'echo $JAVA_LD_LIBRARY_PATH' > $PWD/java_reconf
chmod +x $PWD/java_reconf
JAVA_LD_LIBRARY_PATH=$($R CMD javareconf -e $PWD/java_reconf | tail -n1)
echo "JAVA_LD_LIBRARY_PATH as determined by R CMD javareconf: $JAVA_LD_LIBRARY_PATH"

# Now re-configure to set the correct values.
R CMD javareconf

if [[ ${HOST} =~ .*linux.* ]]; then
  export LD_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
elif [[ ${HOST} =~ .*darwin.* ]]; then
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
