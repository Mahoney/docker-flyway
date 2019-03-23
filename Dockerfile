FROM openjdk:8u191-jre-alpine3.8

WORKDIR /flyway

ENV FLYWAY_VERSION='5.2.4'

RUN apk add --no-cache bash bc

# Install Flyway
RUN wget https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && tar -xzf flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && mv flyway-${FLYWAY_VERSION}/* . \
  && rm flyway-commandline-${FLYWAY_VERSION}.tar.gz \
  && ln -s /flyway/flyway /usr/local/bin/flyway

ADD with_backoff /usr/local/bin/with_backoff
RUN chmod +x /usr/local/bin/with_backoff

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["flyway"]
