########################################
# appdynamics
########################################

# !!! This Dockerfile is not optimized and is only to demo an alpine container running a php project
ARG PHP_VERSION=8.2
FROM docker.io/library/php:${PHP_VERSION}-fpm-alpine

# Useful for php extensions
RUN apk add --no-cache \
    bash \
    curl \
    bzip2 \
    tar

# Useful for appdynamics
ARG AGENT_PATH=/opt/appdynamics
ARG AGENT_VERSION="24.11.0.1340"

# Could be args...
ENV APPDYNAMICS_AGENT_ACCOUNT_NAME=customer1 \
    APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=e7c7cf55-7c28-441b-9851-63aa9d267929 \
    APPDYNAMICS_CONTROLLER_HOST_NAME=appd-collector.example.com \
    APPDYNAMICS_CONTROLLER_PORT=443 \
    APPDYNAMICS_CONTROLLER_SSL_ENABLED=true \
    APPDYNAMICS_AGENT_APPLICATION_NAME=FOO \
    APPDYNAMICS_AGENT_TIER_NAME=foo-bar \
    APPDYNAMICS_AGENT_NODE_NAME=my_node

#ARG APPDYNAMICS_AGENT_LOG_DIR
ENV PHP_AGENT_DIR=${AGENT_PATH}
ENV PHP_AGENT_VERSION=${AGENT_VERSION}

# let see if useful...
ENV LD_LIBRARY_PATH=/usr/glibc-compat/lib:/lib:/usr/lib

RUN mkdir -p ${AGENT_PATH}

#WORKDIR ${AGENT_PATH}

# PHP Agent installation (https://docs.appdynamics.com/display/PRO45/Install+the+PHP+Agent+by+Shell+Script)
RUN mkdir -p ${AGENT_PATH}
COPY appdynamics-php-agent-x64-linux-${AGENT_VERSION}.tar.bz2 ${AGENT_PATH}

# Let see later how to install the proxy - if required?
#COPY appdynamics-php-proxy-x64-alpine-linux-${AGENT_VERSION}.tar.bz2 ${AGENT_PATH}

# Decompress the files
RUN tar -xjf ${AGENT_PATH}/appdynamics-php-agent-x64-linux-${AGENT_VERSION}.tar.bz2 -C ${AGENT_PATH}
#RUN tar -xjf ${AGENT_PATH}/appdynamics-php-proxy-x64-alpine-linux-${AGENT_VERSION}.tar.bz2 -C ${AGENT_PATH}

# Install & instrument AppDynamics PHP Agent
COPY agent-install.sh /agent-install.sh
RUN bash /agent-install.sh


RUN apk add --no-cache \
    gcompat \
    libstdc++

CMD ["bash"]
