#!/bin/bash

# Find Java in the compiler's sysroot
if [[ ${HOST} =~ .*linux.* ]]; then
  export JAVAC=$(find ${BUILD_PREFIX}/${HOST}/sysroot -path "*/bin/javac")
  export JAVAH=$(find ${BUILD_PREFIX}/${HOST}/sysroot -path "*/bin/javah")
  export JAVA=${JAVAC%?}
  export JAR=$(find ${BUILD_PREFIX}/${HOST}/sysroot -path "*/bin/jar")
  # Hack so that sysroot/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.131.x86_64/jre/lib/amd64/libnio.so
  # finds sysroot/usr/lib{64}/libgconf-2.so.4 (horrible..)
  if [[ ${HOST} =~ i686.* ]]; then
    export LD_LIBRARY_PATH=${PREFIX}/lib:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib
  else
    export LD_LIBRARY_PATH=${PREFIX}/lib:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64
  fi
fi

# All this (and it is fairly brittle) just to get the
# value for JAVA_LD_LIBRARY_PATH as determined by:
# R CMD javareconf
echo 'echo $JAVA_LD_LIBRARY_PATH' > $PWD/java_reconf
chmod +x $PWD/java_reconf
JAVA_LD_LIBRARY_PATH=$($R CMD javareconf -e $PWD/java_reconf | tail -n1)
echo "JAVA_LD_LIBRARY_PATH as determined by R CMD javareconf: $JAVA_LD_LIBRARY_PATH"

if [[ $(uname) == Darwin ]]; then
  EREGEX=-e
fi

cp ${PREFIX}/lib/R/bin/javareconf ${RECIPE_DIR}/javareconf.${r_base}
# Now re-configure to set the correct values.
if ! grep 'set -x' ${PREFIX}/lib/R/bin/javareconf > /dev/null; then
  sed -i'' ${EREGEX} '1i\'$'\n''set -x\'$'\n' ${PREFIX}/lib/R/bin/javareconf
fi
R CMD javareconf 2>&1 | tee ${RECIPE_DIR}/R-CMD-javareconf.log
if [[ $? == 0 ]]; then
  echo working > ${DEST}/R-CMD-javareconf-status.log
else
  echo broken > ${DEST}/R-CMD-javareconf-status.log
fi
cp ${RECIPE_DIR}/javareconf.3.4.3.WIP ${PREFIX}/lib/R/bin/javareconf
R CMD javareconf 2>&1 | tee ${RECIPE_DIR}/R-CMD-javareconf-WIP.log
if [[ $? != 0 ]]; then
  OK_R_CMD_JAVARECONF=no
  echo working > ${DEST}/R-CMD-javareconf-WIP-status.log
else
  OK_R_CMD_JAVARECONF=yes
  echo broken > ${DEST}/R-CMD-javareconf-WIP-status.log
fi
cp ${RECIPE_DIR}/javareconf.${r_base} ${PREFIX}/lib/R/bin/javareconf
if [[ ${OK_R_CMD_JAVARECONF} == no ]]; then
  echo "R CMD javareconf failed"
  exit 1
fi

if [[ ${HOST} =~ .*linux.* ]]; then
  export LD_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
elif [[ ${HOST} =~ .*darwin.* ]]; then
  export DYLD_FALLBACK_LIBRARY_PATH=${JAVA_LD_LIBRARY_PATH}:${DYLD_FALLBACK_LIBRARY_PATH}
fi

# R refuses to build packages that mark themselves as Priority: Recommended
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

$R CMD INSTALL --build .

cp "${RECIPE_DIR}"/rjava-dump-details "${PREFIX}"/bin
