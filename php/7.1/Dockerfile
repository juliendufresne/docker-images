# shellcheck disable=SC2148
FROM alpine:3.7

LABEL maintainer="Julien Dufresne"

RUN set -ex; \
        \
        apk update; \
        apk upgrade; \
        # shellcheck disable=SC2046
        apk add \
                curl \
                git \
                openssh \
                php7 \
                $(apk search -v 'php7-*' | sed -E 's/^(php7-[a-z][^-]*)-.*$/\1/g' | grep -vE 'php7-[0-9]+\.[0-9]+\.[0-9]+' | sort); \
    echo "memory_limit=-1" > /etc/php7/conf.d/99_memory-limit.ini; \
    rm -rf /var/cache/apk/* /var/tmp/* /tmp/*; \
    php --version

ENV COMPOSER_CACHE_DIR /composer-cache
ENV COMPOSER_HOME /composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH "$COMPOSER_HOME/vendor/bin:$PATH"
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

VOLUME ["/app"]
WORKDIR /app

RUN set -ex; \
        \
        mkdir -p     "$COMPOSER_CACHE_DIR" /app; \
        chmod -R 777 "$COMPOSER_CACHE_DIR" /etc/php7/conf.d

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

ENV DEFAULT_DOCKER_COMMAND php
