FROM php:7.2

LABEL maintainer="Julien Dufresne"

RUN set -ex; \
        \
        buildDeps='\
            libxml2-dev \
            zlib1g-dev \
        '; \
        apt-get update; \
        apt-get install -y $buildDeps --no-install-recommends; \
        rm -r /var/lib/apt/lists/*; \
        \
        docker-php-ext-install bcmath opcache pdo_mysql soap zip; \
        pecl install xdebug; \
        docker-php-ext-enable xdebug; \
        apt-get purge -y --auto-remove $buildDeps

ENV COMPOSER_CACHE_DIR /composer-cache
ENV COMPOSER_HOME /composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH /composer/vendor/bin:$PATH
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN set -ex; \
        \
        mkdir -p     $COMPOSER_CACHE_DIR /app; \
        chmod -R 777 $COMPOSER_CACHE_DIR /usr/local/etc/php/

VOLUME /app
WORKDIR /app

COPY docker-php-entrypoint-extra /usr/local/bin/
ENTRYPOINT ["docker-php-entrypoint-extra"]
