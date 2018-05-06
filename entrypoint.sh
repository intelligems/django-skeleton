#!/bin/bash

set -xe

if [[ "$RUN_MIGRATIONS" == "1" ]]; then
    # Execute migrations
    ./manage.py migrate --noinput
    # Collect static
    ./manage.py collectstatic --noinput
fi

# Execute subcommand, wrapping
exec "$@"