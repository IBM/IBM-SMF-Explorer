
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

$ErrorActionPreference = "Stop"

$pip_default_opts = @("--no-cache-dir", "--disable-pip-version-check", "--no-input")

# Find and install local smfexplorer wheel file with extras
$wheel_file = Get-ChildItem -Path "./smf_explorer/smfexplorer-*.whl" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($wheel_file) {
    Write-Host "Found local wheel: $($wheel_file.Name)" -ForegroundColor Blue
    Write-Host "Installing local smfexplorer with jupyter extras..." -ForegroundColor Blue
    pip install $pip_default_opts --constraint ".util/constraints.txt" --force-reinstall "$($wheel_file.FullName)[jupyter,jupyter-lab]"
} else {
    Write-Host "ERROR: No smfexplorer wheel file found in ./smf_explorer/" -ForegroundColor Red
    Write-Host "Expected pattern: ./smf_explorer/smfexplorer-*.whl" -ForegroundColor Red
    exit 1
}

# Install any additional requirements
if (Test-Path -Path "requirements.txt") {
    pip install $pip_default_opts --upgrade -r requirements.txt --upgrade-strategy "eager"
}
