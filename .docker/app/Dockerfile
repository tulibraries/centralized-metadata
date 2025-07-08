FROM harbor.k8s.temple.edu/library/ruby:3.4-alpine

WORKDIR /app

COPY . .

USER root

ARG RAILS_ENV=production

RUN apk add -U --no-cache \
      bash=5.2.37-r0 \
      tzdata=2025b-r0 \
      postgresql16-client=16.9-r0 \
      gcompat=1.1.0-r4 \
      libxslt=1.1.43-r3 \
      libstdc++=14.2.0-r6 && \
    apk add -U --no-cache --virtual build-dependencies \
      build-base=0.5-r3 \
      git=2.49.0-r0 \
      yaml-dev=0.2.5-r2 \
      postgresql16-dev=16.9-r0 \
      libxslt-dev=1.1.43-r3 && \
    bundle config set --local without "development test" && \
    bundle install --jobs=8 && \
    find "$GEM_HOME" -name Gemfile.lock -exec rm "{}" \; && \
    rm -rf tmp/* && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/ && \
    mkdir -p /secure-tmp && chmod 700 /secure-tmp && \
    mkdir -p /secure-tmp/log && chmod 700 /secure-tmp/log

USER 65534:65534

ENTRYPOINT [".docker/app/entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
