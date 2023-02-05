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

import subprocess
import os
import signal
import re
import argparse
import getpass

os_var_connection_string = "SMFEXPLORER_CONNECTION_STRING"
os_var_user_name = "SMFEXPLORER_USERNAME"
os_var_user_password = "SMFEXPLORER_PASSWORD"


def select_server(no_tls: bool = False):
    if os_var_connection_string in os.environ:
        print("Connection string found in system environment")
        connection_string = os.environ[os_var_connection_string]
    else:
        connection_string = input(f"What is your connection string?: ")
        connection_string = connection_string.strip()

    if os_var_user_name in os.environ:
        print("User name found in system environment")
        user_name = os.environ[os_var_user_name]
    else:
        user_name = input("Enter your username: ")
        user_name = user_name.strip()

    if os_var_user_password in os.environ:
        print("User password found in system environment")
        user_password = os.environ[os_var_user_password]
    else:
        user_password = getpass.getpass("Enter your password: ")

    match = re.match(
        r"^http[s]?:\/\/(?:[a-zA-Z0-9-]|[.])+(?::[0-9]+)?(?:[a-zA-Z0-9]+)(?:/.*)*$",
        connection_string,
    )
    if match:

        return f"mode=dgapi;url={connection_string};verify_ssl={'false' if no_tls else 'true'};username={user_name};password={user_password}"

    print("Invalid connection string")
    exit(1)


def start_jupyter(connection_string, log: bool = False):
    sig_stopper = signal.signal(signal.SIGINT, signal.SIG_IGN)

    env = os.environ.copy()
    env["SMFPY_CONNECTION_STRING"] = connection_string

    run_list = (
        [
            "jupyter",
            "lab",
            "--notebook-dir=Notebooks",
            "--LabApp.use_redirect_file=False",
        ]
        if os.name == "nt"
        else [f"jupyter lab --notebook-dir=Notebooks --LabApp.use_redirect_file=False"]
    )

    print("Starting Jupyter Lab...")

    subprocess.run(
        run_list, shell=True, env=env, stderr=None if log else subprocess.DEVNULL
    )

    signal.signal(signal.SIGINT, sig_stopper)


parser = argparse.ArgumentParser()

parser.add_argument("--log-output", action="store_true")
parser.add_argument("--no_tls", default=False)


def main():
    try:
        ns = parser.parse_args()
        # Select Server to use
        connection_string = select_server(ns.no_tls)

        start_jupyter(connection_string, log=ns.log_output)
    except KeyboardInterrupt:
        print("")
        pass


if __name__ == "__main__":
    main()
