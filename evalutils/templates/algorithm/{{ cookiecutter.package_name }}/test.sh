#!/usr/bin/env bash

# set -o errexit

# RANDOM_READ_BYTES is tha amount of bytes to read from /dev/urandom.
# No particular reason for any specific value, just something vaguely sensible that provides a
# finite limit on reading from /dev/urandom and gives the message digest (here hard-coded to md5)
# something to calculate on...
RANDOM_READ_BYTES=1024
SCRIPTPATH="$(dirname "$(realpath "${0}")")"

"${SCRIPTPATH}/build.sh"

VOLUME_SUFFIX=$(dd if=/dev/urandom bs=${RANDOM_READ_BYTES} count=1 | md5sum | cut --delimiter=' ' --fields=1)

docker volume create "{{ cookiecutter.package_name|lower }}-output-${VOLUME_SUFFIX}"

docker run --rm \
        -v "${SCRIPTPATH}/test/":/input/ \
        -v "{{ cookiecutter.package_name|lower }}-output-${VOLUME_SUFFIX}":/output/ \
        {{ cookiecutter.package_name|lower }}

docker run --rm \
        -v "{{ cookiecutter.package_name|lower }}-output-${VOLUME_SUFFIX}":/output/ \
        {{ cookiecutter.docker_base_container }} cat /output/results.json | python -m json.tool

docker run --rm \
        -v "{{ cookiecutter.package_name|lower }}-output-$VOLUME_SUFFIX":/output/ \
        -v "${SCRIPTPATH}/test/":/input/ \
        {{ cookiecutter.docker_base_container }} python -c "
import json, sys
jsn1 = json.load(open('/output/results.json'))
jsn2 = json.load(open('/input/expected_output.json'))
if(jsn1 != jsn2):
    sys.exit(-1)
"

if [ $? -eq 0 ]; then
    echo "Tests successfully passed..."
else
    echo "Expected output not found or the generated output did not match the expected output"
fi

docker volume rm "{{ cookiecutter.package_name|lower }}-output-${VOLUME_SUFFIX}"
