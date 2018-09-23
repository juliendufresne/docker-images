ARG PHP_VERSION
FROM juliendufresne/php:$PHP_VERSION

LABEL maintainer="Julien Dufresne"

RUN composer global require \
        friendsofphp/php-cs-fixer:2.13.*

ENV DEFAULT_DOCKER_COMMAND php-cs-fixer
