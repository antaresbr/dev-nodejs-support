ARG NODEJS_VERSION=none
ARG NODEJS_CODENAME=none

FROM node:${NODEJS_VERSION}-${NODEJS_CODENAME}

ARG NODEJS_VERSION=none
ARG NODEJS_CODENAME=none
ARG NODEJS_USERNAME=node
ARG NODEJS_USERID=1000
ARG NODEJS_PORT=none

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

LABEL devcontainer.metadata="[{ \"remoteUser\": \"${NODEJS_USERNAME}\" }]"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y supervisor \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g npm@latest pm2

#-- senha: sail
RUN groupadd --force --gid ${NODEJS_USERID} ${NODEJS_USERNAME}
RUN getent passwd ${NODEJS_USERID} > /dev/null || useradd --create-home --shell /bin/bash --uid ${NODEJS_USERID} --gid ${NODEJS_USERID} ${NODEJS_USERNAME}
RUN mkdir "/home/${NODEJS_USERNAME}/app" \
    && chown -R "${NODEJS_USERNAME}:${NODEJS_USERNAME}" "/home/${NODEJS_USERNAME}" \
    && usermod -aG sudo ${NODEJS_USERNAME} \
    && usermod --password '$6$g/d4Kgna99v5RyE.$I/Pz3TgvRKBQIn7G2EozzPbhjVHj4GvHPryp5gyRkTUN7/u2piwiDZxc/JCBW63/0CnZtSBezhWgrNFqUATkP1' ${NODEJS_USERNAME}

RUN mkdir /tmp/skel
COPY lib/skel /tmp/skel
RUN cat /tmp/skel/custom-rc | sed "s/{{USERNAME}}/${NODEJS_USERNAME}/g" | bash

COPY lib/entrypoint-loop /usr/local/bin/
COPY nodejs/start-container.sh /usr/local/bin/
COPY nodejs/supervisord.conf /etc/supervisor/conf.d/

RUN chmod 755 /usr/local/bin/entrypoint-loop /usr/local/bin/start-container.sh

ENTRYPOINT ["/usr/local/bin/start-container.sh"]

WORKDIR /home/${NODEJS_USERNAME}/app
