FROM project42/s6-alpine:3.7
MAINTAINER Jordan Clark jordan.clark@esu10.org

ENV APP_PACKAGES ruby-json

ENV BUILD_PACKAGES ruby-dev make build-base

COPY . /usr/local/ZabTab

# Install Packages
RUN apk add --no-cache ca-certificates ruby ruby-io-console ruby-bundler && \
apk add --no-cache $APP_PACKAGES $BUILD_PACKAGES && \
umask 0022 && \
echo 'gem: --no-rdoc --no-ri' >/etc/gemrc && \
cd /usr/local/ZabTab && \
bundle install && \
apk del --no-cache $BUILD_PACKAGES

CMD /usr/local/ZabTab/zabtab.rb
