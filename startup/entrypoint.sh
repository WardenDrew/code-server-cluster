#!/bin/bash

if [[ -z "${PORT}" ]]; then
    export PORT=8080;
fi

if [[ -z "${USERNAME}" ]]; then
    export USERNAME="student";
fi

if [[ -z "${PASSWORD}" ]]; then
    export PASSWORD="vscoderocks";
fi

useradd -m -s /bin/bash "${USERNAME}"
echo "${PASSWORD}" | passwd "${USERNAME}" --stdin

exec su "${USERNAME}" -c '/startup/userentrypoint.sh'