#!/usr/bin/env bash

# Global variables
declare -A PROCESSES

# Colors for output
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Help function
function help() {
    echo "proc_ninja.sh [OPTIONS]... [PROCESS_NAME]..."
    echo "Version 1.0"
    echo
    echo "proc_ninja.sh is a robust bash script that searches for and kills processes by name."
    echo "It is designed to be used in a production environment and follows best practices for shell scripting."
    echo
    echo "Options:"
    echo "  -h, --help      Display this help message and exit"
    echo "  -v, --verbose   Display detailed output"
    echo "  --version       Display script version and exit"
    echo
    echo "Examples:"
    echo "  proc_ninja.sh process1 process2"
    echo "  proc_ninja.sh -v process1"
    echo "  proc_ninja.sh --version"
    echo
    echo "Note: This script is still under development and some features may not be fully implemented."
}

# Version function
function version() {
    echo "$0 version 1.0"
}

# Verbose function
function verbose() {
    if [[ $VERBOSE == 1 ]]; then
        echo "${GREEN}$1${RESET}"
    fi
}

# Error function
function error() {
    echo "${RED}$1${RESET}" >&2
    exit 1
}

# Trap function for graceful exit
function cleanup() {
    verbose "Cleaning up..."
    # Add cleanup code here
}

# Function to kill processes
function kill_processes() {
    local process_name=$1
    verbose "Killing processes named '$process_name'..."

    # Get a list of process IDs for the process name
    local pids=$(pgrep -f "$process_name")

    # Kill child processes before parent processes
    for pid in $pids; do
        local child_pids=$(pgrep -P $pid)
        for child_pid in $child_pids; do
            verbose "Killing child process $child_pid..."
            kill $child_pid 2>/dev/null
            if [[ $? -ne 0 ]]; then
                error "Failed to kill child process $child_pid."
                troubleshoot $child_pid
            fi
        done
    done

    # Kill parent processes
    for pid in $pids; do
        verbose "Killing parent process $pid..."
        kill $pid 2>/dev/null
        if [[ $? -ne 0 ]]; then
            error "Failed to kill parent process $pid."
            troubleshoot $pid
        fi
    done
}

# Function to troubleshoot why a process couldn't be killed
function troubleshoot() {
    local pid=$1

    echo "${YELLOW}Troubleshooting why process $pid couldn't be killed...${RESET}"

    # Check if the process is owned by the current user
    local owner=$(ps -o user= -p $pid)
    if [[ $owner != $USER ]]; then
        echo "${RED}The process is owned by $owner, not the current user ($USER). You might not have the necessary permissions to kill it.${RESET}"
    fi

    # Check if the process is a zombie
    local state=$(ps -o state= -p $pid)
    if [[ $state == Z ]]; then
        echo "${RED}The process is a zombie. It has already exited and can't be killed.${RESET}"
    fi

    # Check if the process is a kernel process
    if [[ $pid -lt 100 ]]; then
        echo "${RED}The process is a kernel process. It can't be killed.${RESET}"
    fi

    # Check if the process is ignoring signals
    local ignored_signals=$(grep SigIgn /proc/$pid/status | awk '{ print $2 }')
    if [[ $ignored_signals != 0000000000000000 ]]; then
        echo "${RED}The process is ignoring some signals. It might be ignoring the signal used to kill it.${RESET}"
    fi

    echo "${YELLOW}Check the system logs for more details about why the process couldn't be killed.${RESET}"
    echo "${YELLOW}You might need to use a different signal to kill the process, or kill its parent process or a related daemon.${RESET}"
}

# Main function
function main() {
    trap cleanup EXIT

    # Parse command line options
    while getopts ":hv-:" opt; do
        case $opt in
            h)
                help
                exit 0
                ;;
            v)
                VERBOSE=1
                ;;
            -)
                case $OPTARG in
                    help)
                        help
                        exit 0
                        ;;
                    verbose)
                        VERBOSE=1
                        ;;
                    version)
                        version
                        exit 0
                        ;;
                    *)
                        error "Invalid option --$OPTARG"
                        ;;
                esac
                ;;
            \?)
                error "Invalid option -$OPTARG"
                ;;
            :)
                error "Option -$OPTARG requires an argument"
                ;;
        esac
    done
    shift $((OPTIND -1))

    # Check for process names
    if [[ $# -eq 0 ]]; then
        error "No process names provided"
    fi

    # Add process names to associative array
    for process in "$@"; do
        PROCESSES["$process"]=1
    done

    # Search for and kill processes
    for process in "${!PROCESSES[@]}"; do
        kill_processes "$process"
    done
}

# Run main function
main "$@"