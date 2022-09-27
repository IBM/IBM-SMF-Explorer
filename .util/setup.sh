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

pip_default_opts="--no-cache-dir --no-input --disable-pip-version-check --find-links ./smf_explorer/"

# Upgrade pip because of issues in MacOS BigSur
# python -m pip install $pip_default_opts --upgrade pip setuptools wheel

# Base install
pip install $pip_default_opts --upgrade -r $REQUIREMENTS_FILE --upgrade-strategy eager

if test -f requirements.txt;then
    pip install $pip_default_opts --upgrade -r requirements.txt --upgrade-strategy eager
fi
