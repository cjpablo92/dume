#!/bin/bash

LOG_FILE="/tmp/dume.log"

# ***** cui helper *****
bold=$(tput bold)
normal=$(tput sgr0)

light_blue=$'\e[36m' # light_blue
yellow=$'\e[33m' # yellow
red=$'\e[1;31m' # red
green=$'\e[1;32m' # green
red=$'\e[31m' # red

link_colour=$'\e[36m' # light_blue

# https://misc.flogisoft.com/bash/tip_colors_and_formatting

# ***** cui helper *****

function log_info {
    cur_msg="$(echo -e "[$light_blue INFO $normal] - $1" | sed "s/DONE\!/${green}DONE!${normal}/g" | tee -a $LOG_FILE)"
    [ "$VERBOSE" = true ] && echo -e "$cur_msg" </dev/tty
}

function log_warn {
    cur_msg="$(echo -e "[$yellow WARNING $normal] - $1" | tee -a $LOG_FILE)"
    [ "$VERBOSE" = true ] && echo -e "$cur_msg" </dev/tty
}

function log_error {
    cur_msg="$(echo -e "[$red ERROR $normal] - $1" | tee -a $LOG_FILE)"
    [ "$VERBOSE" = true ] && echo -e "$cur_msg" </dev/tty
}

export -f log_info
export -f log_warn
export -f log_error


function print_msg {
    cur_msg=$(echo -e "[$yellow MSG $normal] - $1")
    echo -e "$cur_msg" </dev/tty
}

function print_raw_line {
    echo -e "------------------------------------------------------------" </dev/tty
}

function print_line {
    print_msg "------------------------------------------------------------"
}

function print_title {
    print_line
    print_msg "$1"
    print_line    
}