FROM php:7.3.19-fpm-alpine

# ref: https://wiki.alpinelinux.org/wiki/Setting_the_timezone
RUN set -x \
    && apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime \
    && echo "Asia/Taipei" > /etc/timezone \
    && apk del tzdata

RUN set -x \
    && apk add --no-cache libmemcached-dev \
    && apk add --no-cache --virtual .deps $PHPIZE_DEPS zlib-dev \
    && pecl install memcached xdebug \
    && docker-php-ext-enable memcached xdebug \
    && apk del --no-network .deps

RUN docker-php-ext-install bcmath pdo_mysql
