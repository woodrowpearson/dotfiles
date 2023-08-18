#!/usr/bin/env python3

import subprocess
import argparse
import re
import sys

def get_brew_info(brew):
    """
    Fetches the brew information in text format and returns it as a string.
    """
    try:
        brew_info_text = subprocess.check_output(["brew", "info", "--formula", brew], stderr=subprocess.STDOUT).decode('utf-8')
        return brew_info_text
    except subprocess.CalledProcessError as e:
        error_message = e.output.decode('utf-8').strip().split('\n')[0]
        print(f"Error: {error_message}")
        return error_message


def get_cask_info(cask):
    """
    Fetches the cask information in text format and returns it as a string.
    """
    try:
        cask_info_text = subprocess.check_output(["brew", "info", "--cask", cask], stderr=subprocess.STDOUT).decode('utf-8')
        return cask_info_text
    except subprocess.CalledProcessError as e:
        error_message = e.output.decode('utf-8').strip().split('\n')[0]
        print(f"Error: {error_message}")
        return error_message


def get_brew_desc(brew):
    """
    Fetches the description of a brew.
    """
    brew_info = get_brew_info(brew)
    if "Error:" in brew_info:
        return brew_info
    brew_desc = brew_info.split('\n')[1] if '\n' in brew_info else ''
    if brew_desc == '':
        print(f"Found {brew} without a description.")
    else:
        print(f"Package {brew} description: {brew_desc}")
    return brew_desc


def get_cask_desc(cask):
    """
    Fetches the description of a cask.
    """
    cask_info = get_cask_info(cask)
    if "Error:" in cask_info:
        return cask_info
    cask_desc = cask_info.split('==> Description\n')[1].split('\n')[0] if '==> Description\n' in cask_info else ''
    if cask_desc == '':
        print(f"Found {cask} without a description.")
    else:
        print(f"Package {cask} description: {cask_desc}")
    return cask_desc


def generate_nix(brews, casks):
    """
    Generates a new homebrew.nix file with descriptions for the brews and casks.
    """
    brews_nix = []
    for brew in brews:
        desc = get_brew_desc(brew)
        if "Error:" in desc:
            brews_nix.append(f'      # "{brew}", # {desc}')
        else:
            brews_nix.append(f'      "{brew}", # {desc}')

    casks_nix = []
    for cask in casks:
        desc = get_cask_desc(cask)
        if "Error:" in desc:
            casks_nix.append(f'      # "{cask}", # {desc}')
        else:
            casks_nix.append(f'      "{cask}", # {desc}')

    return """
{{
  homebrew = {{
    enable = true;

    brews = [
{}
    ];

    casks = [
{}
    ];
  }};

    taps = [
    ];
  }};

    masApps = [
    ];
  }};
}}
""".format(",\n".join(brews_nix), ",\n".join(casks_nix))


def load_file(file_path):
    """
    Loads the file from the given file path.
    """
    with open(file_path, "r") as file:
        file_content = file.read()
    return file_content


def get_brews(file_content):
    """
    Extracts the brews from the file.
    """
    try:
        brews_match = re.search('brews = \[(.*?)\];', file_content, re.DOTALL)
        if brews_match is None:
            print("No 'brews = [' found in file. Check the content of the file.")
            return []
        brews_raw = brews_match.group(1)
        brews = [line.split('"')[1] for line in brews_raw.strip().splitlines() if line.strip().startswith('"')]
        return brews
    except IndexError:
        print("An error occurred: Could not find 'brews = [' in file. Check the content of the file.")
        sys.exit(1)


def get_casks(file_content):
    """
    Extracts the casks from the file.
    """
    try:
        casks_match = re.search('casks = \[(.*?)\];', file_content, re.DOTALL)
        if casks_match is None:
            print("No 'casks = [' found in file. Check the content of the file.")
            return []
        casks_raw = casks_match.group(1)
        casks = [line.split('"')[1] for line in casks_raw.strip().splitlines() if line.strip().startswith('"')]
        return casks
    except IndexError:
        print("An error occurred: Could not find 'casks = [' in file. Check the content of the file.")
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate a homebrew.nix file based on the installed brews and casks.')
    parser.add_argument('-b', '--brews', action='store_true', help='Include brews')
    parser.add_argument('-c', '--casks', action='store_true', help='Include casks')
    parser.add_argument('-f', '--file', type=argparse.FileType('r'), help='The existing file')

    args = parser.parse_args()

    file_content = load_file(args.file.name)

    brews = []
    if args.brews:
        brews = get_brews(file_content)

    casks = []
    if args.casks:
        casks = get_casks(file_content)

    new_file_content = generate_nix(brews, casks)

    with open('new_homebrew.nix', 'w') as f:
        f.write(new_file_content)

    print(f"Updated brews: {brews}")
    print(f"Updated casks: {casks}")
