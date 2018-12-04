#!/bin/bash

set -xe

# Settings check to fail explicitly on wrong configuration.
./manage.py check --deploy --settings={{ project_name }}.settings --fail-level ERROR

if [[ "$RUN_MIGRATIONS" == "1" ]]; then
    # Execute migrations
    ./manage.py migrate --noinput
    # Collect static will be performed on ci stage, after deployment.
    # ./manage.py collectstatic --noinput
fi

# Execute subcommand, wrapping
exec "$@"