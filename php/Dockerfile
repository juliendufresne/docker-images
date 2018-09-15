ARG VERSION

FROM php:$VERSION

ARG USER_ID
ARG GROUP_ID

RUN grep -q ':${GROUP_ID}:' /etc/group || groupadd --gid "${GROUP_ID}" app
RUN useradd --no-log-init \
            --home-dir /home/app \
            --create-home \
            --gid ${GROUP_ID} \
            --shell /bin/bash \
            --uid ${USER_ID} \
            app

RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install -y --no-install-recommends \
                       git \
                       libxml2-dev \
                       zlib1g-dev \
    && rm -r /var/lib/apt/lists/*


# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-install bcmath opcache pdo_mysql soap zip

RUN pecl install xdebug && docker-php-ext-enable xdebug

ENV COMPOSER_CACHE_DIR /composer-cache
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN mkdir -p                    /app $COMPOSER_CACHE_DIR \
    && chown -R app:${GROUP_ID} /app $COMPOSER_CACHE_DIR /usr/local/etc/php/

USER app

VOLUME /app
WORKDIR /app

COPY docker-php-entrypoint-extra /usr/local/bin/
ENTRYPOINT ["docker-php-entrypoint-extra"]
