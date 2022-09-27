
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

# Settings
$INSTALL_FILES = @(".util/common.ps1", ".util/setup.sh", ".util/setup.ps1", ".util/requirements.txt", "setup")
$ENVIRONMENT_PATH = ".setup_venv"
$REQUIREMENTS_FILE = ".util/requirements.txt"

# Arguments
$ARG_RESET = $Reset

$Env:ENVIRONMENT_PATH = $ENVIRONMENT_PATH
$Env:REQUIREMENTS_FILE = $REQUIREMENTS_FILE

# Load dotenv file
if ((Test-Path -Path "./.env.ps1" -PathType Leaf)) {
    . ./.env.ps1
}

# Util Functions
function TestCommand ($command) {
    try {
        Get-Command $command
        return $True
    }
    catch {
        return $False
    }
}

function PrompUserYesOrNo($Prompt, $Default) {
    $prompt_helper = "(y/n)"
    if ($Default -eq "Y") { $prompt_helper = "(Y/n)" }
    elseif ($Default -eq "N") { $prompt_helper = "(y/N)" }
    while ($True) {
        $answer = Read-Host "$Prompt ${prompt_helper}? "
        switch -regex ($answer) {
            "[Yy].*" { return $True }
            "[Nn].*" { return $False }
            Default {
                if ( $Default -eq "Y" ) { return $True }
                elseif ($Default -eq "N") { return $False }
                else {
                    Write-Host "Please select yes or no."
                }
            }
        }
    }

}

$PY = $null
# Find suitable python version
function FindPythonVersion() {
    $python_candidates = @("python", "python3", "python", "py", "python3.9", "python3.8")
    $PYTHON_VERSION_CHECK_CMD = "import platform;major, minor, _ = platform.python_version_tuple();exit(1) if int(major) < 3 or int(minor) < 8 else ();exit(2) if '64' not in platform.architecture()[0] else ();"
    foreach ($candidate in $python_candidates) {
        if (TestCommand $candidate) {
            try {
                if (Invoke-Expression ($candidate + " -c `"${PYTHON_VERSION_CHECK_CMD}`" 2>&1 | out-null " + ';$?')) {
                    $script:PY = $candidate
                    break
                }
            }
            catch {}
        }
    }

    if ($null -eq $PY) {
        Write-Host "No appropriate Python found! Make sure that Python 3.8 64bit or newer is installed and your PATH is setup correctly" -ForegroundColor Red
        exit 1
    }
}

function WriteChecksums() {
    Get-FileHash -Path $INSTALL_FILES | Export-Clixml .util/.setup_sha.xml
}

function CheckChecksums() {
    $checksums = (Import-Clixml .\.util\.setup_sha.xml)

    foreach ($checksum in $checksums) {
        if ((Get-FileHash -Path $checksum.Path).Hash -ne $checksum.Hash) {
            return $False
        }
    }

    return $True
}

function ActivateEnvironment() {
    Write-Host "Activating environment..." -ForegroundColor Blue
    . $ENVIRONMENT_PATH\*\Activate.ps1
}

if (!([Environment]::GetEnvironmentVariable('SMF_EXPLORER_PATH'))) {
    $Env:SMF_EXPLORER_PATH = "../IBM-SMF-Explorer"
}
