FROM harbor.k8s.temple.edu/library/ruby:3.3-alpine

WORKDIR /app

COPY . .

USER root

ARG RAILS_ENV=production

RUN apk add -U --no-cache \
      bash=5.2.37-r0 \
      tzdata=2024b-r1 \
      postgresql16-client=16.6-r0 \
      gcompat=1.1.0-r4 \
      libxslt=1.1.39-r1 && \
    apk add -U --no-cache --virtual build-dependencies \
      build-base=0.5-r3 \
      git=2.45.2-r0 \
      postgresql16-dev=16.5-r0 \
      libxslt-dev=1.1.39-r1 &&\
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
