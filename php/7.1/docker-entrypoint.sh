#!/usr/bin/env sh

XDEBUG_CURRENTLY_ENABLED=0
if ! php -r 'exit(extension_loaded("xdebug") ? 1 : 0);'; then
    XDEBUG_CURRENTLY_ENABLED=1
fi

case "$XDEBUG_ENABLED" in
    '')
        XDEBUG_ENABLED=${XDEBUG_CURRENTLY_ENABLED}
        ;;
    0|1)
        ;;
    *)
        >&2 printf 'value for XDEBUG_ENABLED is not allowed. Set it to 0 to'
        >&2 printf ' disable or 1 to enable xdebug.\n'
        >&2 printf 'Current value: %s\n' "$XDEBUG_ENABLED"
        exit 1
        ;;
esac

if [ $XDEBUG_CURRENTLY_ENABLED != "$XDEBUG_ENABLED" ]; then
    if [ "$XDEBUG_ENABLED" -eq 1 ]; then
        sed -E -i 's/^;zend_extension/zend_extension/' /etc/php7/conf.d/xdebug.ini
    else
        sed -E -i 's/^zend_extension/;zend_extension/' /etc/php7/conf.d/xdebug.ini
    fi
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- "$DEFAULT_DOCKER_COMMAND" "$@"
fi

exec "$@"
