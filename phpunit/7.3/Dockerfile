ARG PHP_VERSION
FROM juliendufresne/php:$PHP_VERSION

LABEL maintainer="Julien Dufresne"

RUN composer global require \
        phpunit/phpunit:7.3.*

ENV DEFAULT_DOCKER_COMMAND phpunit
