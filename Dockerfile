FROM golang:1.15.13

ENV FORCE_COLOR='0'

ARG MIGRATE_VERSION=4.14.1
ARG SQLBOILER_VERSION=4.5.0
ARG STATICCHECK_VERSION=2020.2.4

RUN set -ex; \
    apt-get update --quiet && apt-get upgrade --yes --quiet \
    && apt-get install --quiet --yes \
        jq \
        bats \
        shellcheck \
        python3 \
        python3-pip \
    && mkdir -p /tmp \
    && cd /tmp \
    && GO111MODULE=on go get github.com/volatiletech/sqlboiler/v4@v${SQLBOILER_VERSION} \
    && GO111MODULE=on go get github.com/volatiletech/sqlboiler/v4/drivers/sqlboiler-mysql@v${SQLBOILER_VERSION} \
    && cd - \
    && GO111MODULE=off go get gotest.tools/gotestsum \
    && GO111MODULE=off go get github.com/valyala/quicktemplate/qtc \
    # staticcheck
    && mkdir -p /tmp/staticcheck \
    && cd /tmp/staticcheck \
    && curl -fsSOL https://github.com/dominikh/go-tools/releases/download/$STATICCHECK_VERSION/staticcheck_linux_amd64.tar.gz \
    && tar zxf staticcheck_linux_amd64.tar.gz \
    && chown -R root:root * \
    && mv staticcheck/staticcheck /go/bin/staticcheck \
    && cd - \
    # go-migrate
    && curl -fsSLO https://github.com/golang-migrate/migrate/releases/download/v${MIGRATE_VERSION}/migrate.linux-amd64.tar.gz \
    && tar zxf migrate.linux-amd64.tar.gz \
    && mv migrate.linux-amd64 /usr/bin/migrate \
    && rm -f migrate.linux-amd64.tar.gz \
    # ruleguard
    && GO111MODULE=off go get github.com/quasilyte/go-ruleguard/cmd/ruleguard \
    && GO111MODULE=off go get github.com/quasilyte/go-ruleguard/dsl \
    # semgrep
    && python3 -m pip install semgrep \
    # cleanup
    && rm -rf /tmp/staticcheck \
    && apt remove --quiet --yes python3 python3-pip \
    && apt autoremove --yes --quiet

WORKDIR /build
