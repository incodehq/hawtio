FROM openjdk:8-jre-alpine

ENV HAWTIO_GROUP hawtio
ENV HAWTIO_USER hawtio
ENV HAWTIO_HOME /opt/hawtio
ENV HAWTIO_APP hawtio-app

RUN mkdir -p $HAWTIO_HOME && \
    addgroup -S $HAWTIO_GROUP && \
    adduser -S -H -G $HAWTIO_GROUP -h $HAWTIO_HOME $HAWTIO_USER

WORKDIR $HAWTIO_HOME

ENV HAWTIO_VERSION 2.7.1
ENV PORT=8080
ENV HAWTIO_APP_VERSION $HAWTIO_APP-$HAWTIO_VERSION
ENV HAWTIO_APP_VERSION_JAR $HAWTIO_APP-$HAWTIO_VERSION.jar
ENV HAWTIO_APP_JAR $HAWTIO_APP.jar
ENV HAWTIO_APP_JAR_SHA512=0acafd201128a143870d501d0bde9097fc42f4eddee39822e2fa6587470b38ad2565054ecb734314026696330837fb12d6696a72c0f11c13a8eae487de73c3ea

RUN apk --update add --virtual build-dependencies curl && \
    curl https://oss.sonatype.org/content/repositories/public/io/hawt/$HAWTIO_APP/$HAWTIO_VERSION/$HAWTIO_APP_VERSION_JAR -o $HAWTIO_HOME/$HAWTIO_APP_VERSION_JAR && \
    find $HAWTIO_HOME -print

RUN if [ "$HAWTIO_APP_JAR_SHA512" != "$(sha512sum $HAWTIO_HOME/$HAWTIO_APP_VERSION_JAR | awk '{print($1)}')" ];\
    then \
        echo "sha512 value for $HAWTIO_APP_VERSION_JAR doesn't match! exiting."  && \
        exit 1; \
    fi;

RUN ln -s $HAWTIO_HOME/$HAWTIO_APP_VERSION_JAR $HAWTIO_HOME/$HAWTIO_APP_JAR && \
    chown -R $HAWTIO_USER:$HAWTIO_GROUP $HAWTIO_HOME/$HAWTIO_APP_VERSION_JAR && \
    chown -R $HAWTIO_USER:$HAWTIO_GROUP $HAWTIO_HOME/$HAWTIO_APP_JAR && \
    chown -h $HAWTIO_USER:$HAWTIO_GROUP $HAWTIO_HOME && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

COPY src/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

#USER $HAWTIO_USER
EXPOSE $PORT

CMD /entrypoint.sh
