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

# Colors
RED="$(tput setaf 1)"
BLUE="$(tput setaf 4)"
ORANGE="$(tput setaf 3)"
BOLD="$(tput bold)"
NC="$(tput sgr0)"

# Check OS Type
#system="$(uname -s)"
case "$(uname -s)" in
    CYGWIN*)    MACHINE=Windows;;
    MINGW*)     MACHINE=Windows;;
    MSYS*)      MACHINE=Windows;;
    Darwin*)    MACHINE=Darwin;;
    *)          MACHINE=Unix;;
esac

# Settings
INSTALL_FILES=(".util/common.sh" ".util/setup.sh" ".util/requirements.txt" "setup")
ENVIRONMENT_PATH=".setup_venv"
REQUIREMENTS_FILE=".util/requirements.txt"

# Arguments
ARG_RESET=false

# Load dotenv file
if [[ -f "./.env" ]];then
    set -a
    source ./.env
    set +a
fi

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--reset)
                ARG_RESET=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Util Functions

command_exists() {
    type "$1" &> /dev/null ;
}

prompt_user_yes_or_no() {
    if [[ ${2:-} = "Y" ]]; then prompt_help="(${BOLD}Y${NC}/n)"
    elif [[ ${2:-} = "N" ]]; then prompt_help="(y/${BOLD}N${NC})"
    else prompt_help="(y/n)"; fi

    while true; do
        read -p "$1 $prompt_help?: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * )
                if [[ ${2:-} = "Y" ]];then return 0;
                elif [[ ${2:-} = "N" ]]; then return 1;
                else echo "Please select ${BOLD}yes${NC} or ${BOLD}no${NC}."; fi
                ;;
        esac
    done
}

# Find suitable python version
find_python_version() {
    PY=""
    local CANDIDATES=("python" "python3" "python3.9" "python3.8")
    local PYTHON_VERSION_CHECK_CMD="import platform;major, minor, _ = platform.python_version_tuple();exit(1) if int(major) < 3 or int(minor) < 8 else ();exit(2) if '64' not in platform.architecture()[0] else ();"
    for candidate in "${CANDIDATES[@]}"; do
        if command_exists $candidate; then
            if $candidate -c "$PYTHON_VERSION_CHECK_CMD";then
                PY="$candidate"
                break
            fi
        fi
    done
    if [[ $PY = "" ]]; then
        echo -e "${RED}No appropriate Python found! Make sure that Python 3.8 64bit or newer is installed and your PATH is setup correctly${NC}"
        exit 1
    fi
}

# Write Checksums
write_checksums() {
    if [[ "$MACHINE" = "Darwin" ]];then
        shasum ${INSTALL_FILES[*]} > .util/.setup.sha1
    else
        sha1sum ${INSTALL_FILES[*]} > .util/.setup.sha1
    fi
}

check_checksums() {
    if [[ "$MACHINE" = "Darwin" ]]; then
        shasum -c .util/.setup.sha1 &> /dev/null
        return $?
    else
        sha1sum -c .util/.setup.sha1 &> /dev/null
        return $?
    fi
}

activate_environment() {
    echo -e "${BLUE}Activating environment${NC}..."
    source $ENVIRONMENT_PATH/bin/activate
}

export ENVIRONMENT_PATH
export REQUIREMENTS_FILE

if [[ -z "${SMF_EXPLORER_PATH+x}" ]]; then
    SMF_EXPLORER_PATH="../IBM-SMF-Explorer"
fi

export SMF_EXPLORER_PATH
