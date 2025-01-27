#!/bin/bash

# updates the bash script for the custom extension

az storage blob upload \
    --account-name sqsandboxpostdeployment \
    --container-name bashfile \
    --name "postdeploy.sh" \
    --file "postdeploy.sh" \
    --auth-mode key \
    --account-key $key \
    --overwrite


