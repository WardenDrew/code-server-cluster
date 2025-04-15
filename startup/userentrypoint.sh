#!/bin/bash

mkdir -p /config
mkdir -p /projects

cp -vnpr /default/config/* /config
cp -vnpr /default/projects/* /projects
cp -vnpr /default/.bashrc "/home/${USERNAME}/.bashrc"

exec /app/code-server/bin/code-server \
    --bind-addr "0.0.0.0:${PORT}" \
    --user-data-dir /config/data \
    --extensions-dir /config/extensions \
    --disable-telemetry \
    --auth password \
    --disable-workspace-trust \
    --ignore-last-opened