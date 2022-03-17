from enum import Enum
import sys
from pathlib import Path
from typing import List, Optional
import re
from getpass import getpass
import crypt
import secrets
import json


class UserType(Enum):
    NEW = "NEW"
    EDIT = "EDIT"


# Thanks https://unix.stackexchange.com/a/435120
USER_REGEX = re.compile("^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$")


def request_user_type() -> UserType:
    while True:
        print("Enter the user type n:new e:edit. (N/e)")
        value = input().lower()
        if value == "" or value == "n":
            return UserType.NEW
        elif value == "e":
            return UserType.EDIT
        else:
            print("That is not a valid user type!")


def request_user_name() -> str:
    while True:
        print("Enter the name of the user:")
        r = input()
        if USER_REGEX.match(r) is not None:
            return r
        else:
            print("That is not a valid name!")


def request_password() -> Optional[str]:
    print("Enter the password for this user. (You will not see your input) (Leave blank to skip):")
    password = getpass()
    if password == "":
        return None
    return password


def request_boolean(default_value=None) -> bool:
    if default_value is None:
        prompt = "(y/n)"
    elif default_value:
        prompt = "(Y/n)"
    else:
        prompt = "(y/N)"
    value = input(prompt).lower()
    if "n" in value:
        return False
    elif "y" in value:
        return True
    elif not value and default_value is not None:
        return default_value
    return request_boolean(default_value)


def create_user_config() -> dict:
    user_type = request_user_type()
    r = {
        "type": user_type.name,
        "name": request_user_name()
    }
    password = request_password()
    if password is not None:
        salt = secrets.token_hex(8)
        encrypted_password = crypt.crypt(password, salt)
        r["password"] = encrypted_password
    elif user_type == UserType.EDIT:
        # only ask if they want to lock if they did not change the users password
        print("Would you like to lock logins to this account?")
        r["lock"] = request_boolean(False)

    if user_type == UserType.NEW:
        print("Is this a system user?", end="")
        r["system"] = request_boolean(False)
        print("Should a home directory be created?", end="")
        r["create_home"] = request_boolean(True)

    return r


def main(args: List[str]) -> int:
    if len(args) != 1:
        print("Usage <... command> <output json file>")
        return 1
    file = Path(args[0])
    if file.exists():
        print(f"{file} exists! It will be overwritten. Press enter to continue.")
        input()
    print("Welcome to the user configuration program!")
    print(f"This program will ask you questions then save your configuration to {file}")
    print("Whenever you are asked for a list of groups, it should take the format: group1,group2,group3\n\tThere should be no spaces in between groups.")
    print()
    users = []
    while True:
        users.append(create_user_config())
        print("Do you have another user?")
        if not request_boolean(True):
            break

    root = {
        "users": users
    }
    json_data = json.dumps(root)

    with file.open("w") as stream:
        stream.write(json_data)

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
