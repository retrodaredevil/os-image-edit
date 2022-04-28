#!/usr/bin/env python3
import json
import shutil
import sys
import traceback
from pathlib import Path
import subprocess
from typing import Optional, List


def get_home_directory(user: str) -> Path:
    # Thanks https://stackoverflow.com/a/13332300/5434860
    process = subprocess.Popen(["echo", "echo ~" + user], stdout=subprocess.PIPE)
    result = subprocess.check_output(["bash"], stdin=process.stdout)
    process.wait()
    return Path(result.decode("utf-8")[:-1])


def main(args) -> int:
    file = Path("/opt/config_files/users.json")
    try:
        json_data = file.read_text("UTF-8")
    except FileNotFoundError as ex:
        traceback.print_exception(type(ex), ex, ex.__traceback__)
        print("Did not find the users.json file! Make sure to run make config-users")
        return 0
    root = json.loads(json_data)
    print(root)
    for user in root["users"]:
        command = []
        name = user["name"]
        if user["type"] == "NEW":
            command.append("useradd")
            command.append(name)
            if user["system"]:
                command.append("--system")
            if user["create_home"]:
                command.append("--create-home")
            else:
                command.append("--no-create-home")
        elif user["type"] == "EDIT":
            command.append("usermod")
            command.append(name)
            if user.get("lock"):
                command.append("--lock")
        else:
            raise ValueError(f'Unknown type: {user["type"]}')

        password = user.get("password")
        if password:
            command.append("--password")  # usermod and useradd both use this flag
            command.append(password)

        groups = user.get("groups")
        if groups:
            command.append("--groups")  # usermod and useradd both use this flag
            command.append(groups)

        if len(command) <= 2:
            print(f"Not running command: {command}")
        else:
            exit_code = subprocess.call(command)
            if exit_code != 0:
                print(f"Got exit code of {exit_code} for command: {command}. Exiting!")
                return exit_code
            # Now the user should be fully created
            print(f"Successfully ran command: {command}")

        if user["type"] != "EDIT" and user.get("lock"):
            passwd_exit_code = subprocess.call(["passwd", "--lock", name])
            if passwd_exit_code != 0:
                print(f"Could not lock {name}! exit code: {passwd_exit_code}. Exiting!")
                return passwd_exit_code
            print(f"Successfully locked {name}")

        ssh_authorized: List[str] = user.get("ssh_authorized") or []
        if ssh_authorized:
            ssh_directory = Path(get_home_directory(name), ".ssh")
            ssh_directory.mkdir(mode=0o700, exist_ok=True)  # parents=False because the home directory should already be created
            shutil.chown(ssh_directory, user=name, group=name)  # we assume that each user has their own group
            ssh_authorized_file = Path(ssh_directory, f"authorized_keys")
            print(f"Going to add authorized keys to {ssh_authorized_file}")
            with ssh_authorized_file.open("a") as stream:
                for authorized_key in ssh_authorized:
                    stream.write(authorized_key.strip() + "\n")
            ssh_authorized_file.chmod(0o600)
            shutil.chown(ssh_authorized_file, user=name, group=name)

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
