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

#Changing into working directory
Set-Location -Path $PSScriptRoot

# Load Common Functions
. ./.util/common.ps1

# Pre flight checks
if (!(Test-Path -Path ".\.util\.setup_sha.xml")) {
    Write-Host "It looks like there is no valid setup. Run './setup.bat' to install an environment" -ForegroundColor Red
    exit 1
}
if (!(CheckChecksums)) {
    Write-Host "There are updates to some configuration files. Run './setup.bat' again to reinstall the environment" -ForegroundColor Yellow
    if (!(PrompUserYesOrNo -Prompt "Do you want to continue without updating" -Default "N")) {
        exit
    }
}


if ( -Not (TestCommand python)) {
    Write-Host "Python not found! Make sure that Python is installed and your PATH is set up correctly" -ForegroundColor Red
    exit 1
}

if (!(Test-Path -Path $ENVIRONMENT_PATH -PathType Container)) {
    Write-Host "No environment found. Run './setup.bat' to install environment" -ForegroundColor Red
    exit 1
}

ActivateEnvironment

try {
    $arguments = $args
    python .\.util\start.py $arguments
}
finally {
    deactivate
}
