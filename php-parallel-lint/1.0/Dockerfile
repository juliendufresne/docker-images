ARG PHP_VERSION
FROM juliendufresne/php:$PHP_VERSION

LABEL maintainer="Julien Dufresne"

RUN composer global require \
        jakub-onderka/php-console-highlighter \
        jakub-onderka/php-parallel-lint:1.0.*

ENV DEFAULT_DOCKER_COMMAND parallel-lint
