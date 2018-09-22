FROM alpine:3.8

LABEL maintainer="Julien Dufresne"

RUN set -ex; \
        \
        apk --update --progress --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.8/community add \
                curl \
                php7 \
                php7-ctype \
                php7-curl \
                php7-dom \
                php7-fileinfo \
                php7-ftp \
                php7-iconv \
                php7-json \
                php7-mbstring \
                php7-mysqlnd \
                php7-openssl \
                php7-pdo \
                php7-pdo_sqlite \
                php7-phar \
                php7-posix \
                php7-session \
                php7-simplexml \
                php7-sqlite3 \
                php7-tokenizer \
                php7-xml \
                php7-xmlreader \
                php7-xmlwriter \
                php7-zlib; \
    echo "memory_limit=-1" > /etc/php7/conf.d/99_memory-limit.ini; \
    rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

ENV COMPOSER_CACHE_DIR /composer-cache
ENV COMPOSER_HOME /composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH /composer/vendor/bin:$PATH
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["phpstan"]

RUN composer global require \
        phpstan/phpstan:0.10.* \
        phpstan/phpstan-beberlei-assert \
        phpstan/phpstan-deprecation-rules \
        phpstan/phpstan-dibi \
        phpstan/phpstan-doctrine \
        phpstan/phpstan-mockery \
        phpstan/phpstan-nette \
        phpstan/phpstan-php-parser \
        phpstan/phpstan-phpunit \
        phpstan/phpstan-strict-rules \
        phpstan/phpstan-symfony \
        phpstan/phpstan-webmozart-assert \
        jangregor/phpstan-prophecy

