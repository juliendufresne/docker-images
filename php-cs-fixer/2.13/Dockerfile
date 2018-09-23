# shellcheck disable=SC2148
ARG PHP_VERSION
# shellcheck disable=SC2086
FROM juliendufresne/php:$PHP_VERSION

LABEL maintainer="Julien Dufresne"

RUN composer global require \
        friendsofphp/php-cs-fixer:2.13.*

ENV DEFAULT_DOCKER_COMMAND php-cs-fixer
