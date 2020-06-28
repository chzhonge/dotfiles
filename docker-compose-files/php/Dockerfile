FROM php:7.3.19-fpm-alpine

RUN apk update \
    && apk add --no-cache --update libmemcached-libs zlib \
    && apk add iputils \
    && apk add $PHPIZE_DEPS && pecl install xdebug && \
    echo 'zend_extension=xdebug.so' > /usr/local/etc/php/conf.d/docker-php-xdebug.ini

# ref https://stackoverflow.com/questions/40894385
ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev
RUN set -xe \
    && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
    && pecl install memcached \
    && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
    && rm -rf /usr/share/php7 \
    && rm -rf /tmp/* \
    && apk del .memcached-deps .phpize-deps
