FROM harbor.k8s.temple.edu/library/ruby:3.1.0-alpine

WORKDIR /app

COPY . .

USER root

ARG RAILS_ENV=production

RUN apk add -U --no-cache \
      bash=5.1.8-r0 \
      tzdata=2021e-r0 \
      postgresql14-client=14.1-r5 \
      libxslt=1.1.34-r1 && \
    apk add -U --no-cache --virtual build-dependencies \
      build-base=0.5-r2 \
      git=2.34.1-r0 \
      postgresql14-dev=14.1-r5 \
      libxslt-dev=1.1.34-r1 && \
    gem install bundler:2.3.3 && \
    bundle config build.nokogiri --use-system-libraries && \
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
