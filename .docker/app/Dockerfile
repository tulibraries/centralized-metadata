FROM harbor.k8s.temple.edu/library/ruby:3.1-alpine

WORKDIR /app

COPY . .

USER root

ARG RAILS_ENV=production

RUN apk add -U --no-cache \
      bash=5.2.21-r0 \
      tzdata=2023d-r0 \
      postgresql14-client=14.10-r0 \
      gcompat=1.1.0-r4 \
      libxslt=1.1.39-r0 && \
    apk add -U --no-cache --virtual build-dependencies \
      build-base=0.5-r3 \
      git=2.43.0-r0 \
      postgresql14-dev=14.10-r0 \
      libxslt-dev=1.1.39-r0 &&\
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
