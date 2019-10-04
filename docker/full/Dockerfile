# create layer to cache the .gradle folder
# this probably doesn't achieve goal b/c any change to gradle files will invalidate layers
FROM adoptopenjdk/openjdk11:alpine-slim AS cachedeps
COPY ./src cas-overlay/src/
COPY ./gradle/ cas-overlay/gradle/
COPY ./gradlew ./settings.gradle ./build.gradle ./gradle.properties /cas-overlay/
RUN mkdir -p ~/.gradle \
    && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties \
    && echo "org.gradle.configureondemand=true" >> ~/.gradle/gradle.properties \
    && cd cas-overlay \
    && chmod 750 ./gradlew \
    && ./gradlew --version;

# build war with all support jars
RUN cd cas-overlay \
    && ./gradlew clean build -PbuildAll=true  --parallel;

# run build with .gradle (cache) folder from previous build
FROM adoptopenjdk/openjdk11:alpine-slim AS overlay

RUN mkdir -p cas-overlay
COPY ./src cas-overlay/src/
COPY ./gradle/ cas-overlay/gradle/
COPY ./gradlew ./settings.gradle ./build.gradle ./gradle.properties /cas-overlay/

RUN cd cas-overlay \
    && chmod 750 ./gradlew \
    && ./gradlew --version;

COPY --from=cachedeps /root/.gradle /root

# build war with all support jars in lib folder rather than in war
RUN cd cas-overlay \
    && ./gradlew clean build -PbuildAll=true  --parallel;

RUN cd cas-overlay/build/libs/ && \
    jar xf cas.war && \
    mkdir ../support && \
    rm cas.war && \ 
    mv WEB-INF/lib/cas-server-support*.jar ../support && \
    jar --create --file cas.war --manifest=META-INF/MANIFEST.MF --no-compress .

# build runtime image with war and support libs from previous layer
FROM adoptopenjdk/openjdk11:alpine AS cas

LABEL "Organization"="Apereo"
LABEL "Description"="Apereo CAS"

RUN cd / \
    && mkdir -p /etc/cas/config \
    && mkdir -p /etc/cas/services \
    && mkdir -p /etc/cas/saml \
    && mkdir -p cas-overlay \
    && apk update && apk add bash

COPY etc/cas/ /etc/cas/
COPY etc/cas/config/ /etc/cas/config/
COPY etc/cas/services/ /etc/cas/services/
COPY etc/cas/saml/ /etc/cas/saml/
COPY --from=overlay cas-overlay/build/libs/cas.war cas-overlay/
COPY --from=overlay cas-overlay/build/support cas-overlay/support
EXPOSE 8080 8443

ENV PATH $PATH:$JAVA_HOME/bin:.
ENV SUPPORT_LIBS=""
ADD docker/full/start_cas.sh cas-overlay

WORKDIR cas-overlay
ENTRYPOINT ["/cas-overlay/start_cas.sh"]
CMD [ "${VERSION}" ]
