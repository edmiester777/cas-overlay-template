#!/bin/bash

DEFAULT_JVM_ARGS=-Xmx2048M
JVM_ARGS=${JVM_ARGS:-$DEFAULT_JVM_ARGS}

CLOUD_VAULT_CONFIG=${CLOUD_VAULT_CONFIG:-false}
CLOUD_CONSUL_CONFIG=${CLOUD_CONSUL_CONFIG:-false}
CLOUD_ZOOKEEPER_CONFIG=${CLOUD_ZOOKEEPER_CONFIG:-false}

VERSION=6.1.0-RC5-SNAPSHOT
DEFAULT_SUPPORT_LIBS=actions,geolocation,jpa-util,ldap-core,pac4j-api,pac4j-authentication,pac4j-core,person-directory,themes,token-core-api,validation,validation-core
SUPPORT_LIBS=$DEFAULT_SUPPORT_LIBS,$SUPPORT_LIBS

if [[ ! -z ${SUPPORT_LIBS} ]]; then
    if [[ ! -d /cas-overlay/libs ]] ; then
        mkdir /cas-overlay/libs
    fi
    rm -f /cas-overlay/libs/*
    for SUPPORT_LIB in $(echo $SUPPORT_LIBS | sed "s/,/ /g")
    do
        if [[ ! -z ${SUPPORT_LIB} ]] ; then
            echo "Linking support library ${SUPPORT_LIB}"
            ln -s /cas-overlay/support/cas-server-support-${SUPPORT_LIB}-${VERSION}.jar /cas-overlay/libs/cas-server-support-${SUPPORT_LIB}.jar 
        fi
    done
fi

exec /opt/java/openjdk/bin/java -server -noverify $JVM_ARGS -jar cas.war --loader.path=/cas-overlay/libs --spring.cloud.zookeeper.enabled=${CLOUD_ZOOKEEPER_CONFIG} --spring.cloud.amqp.enabled=false --spring.cloud.vault.enabled=${CLOUD_VAULT_CONFIG} --spring.cloud.consul.enabled=${CLOUD_CONSUL_CONFIG} --eureka.client.enabled=false --spring.zipkin.enabled=false --spring.sleuth.enabled=false --ribbon.eureka.enabled=false --feign.hystrix.enabled=false