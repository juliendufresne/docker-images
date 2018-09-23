# shellcheck disable=SC2148
ARG PHP_VERSION
# shellcheck disable=SC2086
FROM juliendufresne/php:$PHP_VERSION

LABEL maintainer="Julien Dufresne"

RUN composer global require \
        phpunit/phpunit:7.3.*

ENV DEFAULT_DOCKER_COMMAND phpunit
