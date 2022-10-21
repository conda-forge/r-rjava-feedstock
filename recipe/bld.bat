export JAVA_HOME="%PREFIX%/Library"
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1
