#!/bin/bash

# This is a standard entrypoint script.
# It ensures that any command passed to `docker run` is executed.

set -e # Exit immediately if a command fails

# The "$@" part means "all the arguments passed to this script".
# In our case, it will be the default "bash" command from the Dockerfile's CMD.
exec "$@"