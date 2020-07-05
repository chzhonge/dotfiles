FROM php:7.3-cli-alpine

ENV SWOOLE_VERSION=4.3.4

RUN apk add --no-cache \
        $PHPIZE_DEPS \
        openssl-dev

RUN set -xe && \
        pecl install swoole-${SWOOLE_VERSION} && \
        docker-php-ext-install mysqli pdo pdo_mysql && \
        docker-php-ext-enable swoole
