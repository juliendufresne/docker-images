ARG PHP_VERSION
FROM juliendufresne/php:$PHP_VERSION

LABEL maintainer="Julien Dufresne"

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

ENV DEFAULT_DOCKER_COMMAND phpstan
