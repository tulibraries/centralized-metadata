FROM harbor.k8s.temple.edu/library/ruby:3.1-alpine

WORKDIR /app

COPY . .

USER root

ARG RAILS_ENV=production

RUN apk add -U --no-cache \
      bash=5.2.15-r0 \
      tzdata=2022f-r1 \
      postgresql14-client=14.6-r1 \
      libc6-compat=1.2.3-r4 \
      libxslt=1.1.37-r0 && \
    apk add -U --no-cache --virtual build-dependencies \
      build-base=0.5-r3 \
      git=2.38.3-r1 \
      postgresql14-dev=14.6-r1 \
      libxslt-dev=1.1.37-r0 &&\
    bundle config set --local without "development test" && \
    bundle install --jobs=8 && \
    find "$GEM_HOME" -name Gemfile.lock -exec rm "{}" \; && \
    rm -rf tmp/* && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/ && \
    chown nobody -R /app/tmp && \
    chown nobody -R /app/log

USER nobody

ENTRYPOINT [".docker/app/entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
