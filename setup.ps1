#!/usr/bin/env pwsh
param(
    [Switch]$Reset
)

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

# Setup Environment
$ErrorActionPreference = "Stop"

# Changing into working directory
Set-Location -Path $PSScriptRoot

# Load Common Functions
. ./.util/common.ps1

FindPythonVersion

# Run setup
if ($ARG_RESET) {
    Write-Host "Recreating virtual environment..." -ForegroundColor Blue
    if (-Not(Invoke-Expression $PY" -m venv --copies --clear --upgrade-deps "$ENVIRONMENT_PATH';$?')) {
        exit 1
    }
}
elseif (Test-Path -Path $ENVIRONMENT_PATH -PathType Container) {
    Write-Host "Updating virtual environment..." -ForegroundColor Blue
    if (-Not(Invoke-Expression $PY" -m venv --copies --upgrade --upgrade-deps "$ENVIRONMENT_PATH';$?')) {
        exit 1
    }
}
else {
    Write-Host "Creating virtual environment..." -ForegroundColor Blue
    if (-Not(Invoke-Expression $PY" -m venv --copies --upgrade-deps "$ENVIRONMENT_PATH';$?')) {
        exit 1
    }
}

ActivateEnvironment

try {
    Write-Host "Running basic installation..." -ForegroundColor Blue
    .\.util\setup.ps1
}
finally {
    deactivate
}

WriteChecksums
