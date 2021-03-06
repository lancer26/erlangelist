FROM mhart/alpine-node:5.6.0

# install OS packages
RUN echo 'http://dl-4.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
    && echo 'http://dl-4.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk --update add \
        ncurses-libs=6.0-r7 \
        elixir=1.2.1-r0 erlang-runtime-tools erlang-snmp erlang-crypto erlang-syntax-tools \
        erlang-inets erlang-ssl erlang-public-key erlang-eunit \
        erlang-asn1 erlang-sasl erlang-erl-interface erlang-dev \
        wget git curl \
    && rm -rf /var/cache/apk/*
RUN mix local.hex --force && mix local.rebar --force

# fetch & compile deps
COPY site/mix.exs site/mix.lock site/package.json /tmp/erlangelist/site/
RUN cd /tmp/erlangelist/site \
    && mix deps.get \
    && MIX_ENV=prod mix deps.compile \
    && MIX_ENV=test mix deps.compile \
    && npm install -g brunch \
    && npm install

# copy the entire site & build the release
COPY site /tmp/erlangelist/site
RUN cd /tmp/erlangelist/site \
    && MIX_ENV=prod mix compile \
    && brunch build --production \
    && MIX_ENV=prod mix phoenix.digest \
    && MIX_ENV=prod mix release --no-confirm-missing
