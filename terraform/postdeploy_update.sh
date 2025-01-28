#!/bin/bash

# updates the bash script for the custom extension

BLOB_FILENAME='postdeploy.sh'

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
fi

# echo "${key}"

az storage blob upload \
    --account-name sqsandboxpostdeployment \
    --container-name bashfile \
    --name ${BLOB_FILENAME} \
    --file ${BLOB_FILENAME} \
    --auth-mode key \
    --account-key ${key} \
    --overwrite