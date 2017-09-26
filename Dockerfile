FROM ruby:2.4-stretch

ARG branch=master
ARG version

ENV name="rOCCI-server"
ENV username="rocci" \
    appDir="/opt/${name}" \
    logDir="/var/log/${name}" \
    TERM="xterm"

LABEL application=${name} \
      description="rOCCI server" \
      maintainer="kimle@cesnet.cz" \
      version=${version} \
      branch=${branch}

SHELL ["/bin/bash", "-c"]

RUN git clone https://github.com/the-rocci-project/rOCCI-server.git ${appDir}

RUN useradd --system --shell /bin/false --home ${appDir} ${username} && \
    usermod -L ${username} && \
    mkdir -p ${appDir}/log && \
    ln -s ${appDir}/log ${logDir} && \
    chown -R ${username}:${username} ${appDir} ${appDir}/log ${logDir}

USER ${username}

VOLUME ["${logDir}"]

WORKDIR ${appDir}

RUN bundle install --path ./vendor --deployment --without development test

EXPOSE 3000

ENTRYPOINT ["bundle", "exec", "--keep-file-descriptors", "puma"]
