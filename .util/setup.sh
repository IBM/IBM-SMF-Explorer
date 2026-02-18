#!/usr/bin/env bash

#
# Copyright 2022 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -eou pipefail
# Upgrade pip because of issues in MacOS BigSur
# python -m pip install $pip_default_opts --upgrade pip setuptools wheel

pip_default_opts="--no-cache-dir --no-input --disable-pip-version-check"

# Find and install local smfexplorer wheel file with extras
wheel_file=$(ls ./smf_explorer/smfexplorer-*.whl 2>/dev/null | head -n 1)

if [[ -n "$wheel_file" ]]; then
    echo "Found local wheel: $wheel_file"
    echo "Installing local smfexplorer with jupyter extras..."
    pip install $pip_default_opts --constraint .util/constraints.txt --force-reinstall "${wheel_file}[jupyter,jupyter-lab]"
else
    echo "ERROR: No smfexplorer wheel file found in ./smf_explorer/"
    echo "Expected pattern: ./smf_explorer/smfexplorer-*.whl"
    exit 1
fi

# Install any additional requirements
if test -f requirements.txt;then
    pip install $pip_default_opts --upgrade -r requirements.txt --upgrade-strategy eager
fi
