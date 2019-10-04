#!/bin/bash
image_tag=(`cat ../../gradle.properties | grep "cas.version" | cut -d= -f2`)

docker run --rm -p 8443:8443 -p 8080:8080 --name cas org.apereo.cas/cas:$image_tag