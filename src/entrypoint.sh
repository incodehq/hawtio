#!/bin/sh

echo "starting hawt.io:"

# run at root context path
java -Dhawtio.proxyWhitelist=* -jar /opt/hawtio/hawtio-app.jar -c /
