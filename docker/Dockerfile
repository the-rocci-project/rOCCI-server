FROM ruby:2.4-stretch

ARG branch=master
ARG version

ENV name="rOCCI-server" \
    project="the-rocci-project" \
    installDir="/opt"
ENV username="rocci" \
    appDir="${installDir}/${name}-${version}" \
    logDir="/var/log/${name}" \
    TERM="xterm"

LABEL application=${name} \
      description="rOCCI server" \
      maintainer="kimle@cesnet.cz" \
      version=${version} \
      branch=${branch}

SHELL ["/bin/bash", "-c"]

RUN curl -SsL https://github.com/${project}/${name}/archive/v${version}.tar.gz | tar -xzC ${installDir}

RUN useradd --system --shell /bin/false --home ${appDir} ${username} && \
    usermod -L ${username} && \
    mkdir -p ${appDir}/log && \
    ln -s ${appDir}/log ${logDir} && \
    chown -R ${username}:${username} ${appDir} ${appDir}/log ${logDir}

COPY bin/* /rocci/bin/

USER ${username}

VOLUME ["${logDir}"]

WORKDIR ${appDir}

RUN bundle install --path ./vendor --deployment --without development test

EXPOSE 3000

ENTRYPOINT ["/rocci/bin/rocci-wrapper.sh"]
