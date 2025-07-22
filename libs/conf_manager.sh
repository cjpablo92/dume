#!/bin/bash

export EMPTY="<empty>"

export CONFIG_FOLDER="$HOME/.config/dume"
export CONFIG_KEY_VALUE_FOLDER="$HOME/.config/dume/key-values"

export LINUX_PATH_FOLDER="$HOME/.local/bin"
export MAC_PATH_FOLDER="/usr/local/bin"

# TODO: grep -R 'dume' $HOME/.local/bin | cut -d: -f1 | rev | cut -d'/' -f1 | rev


# --------------- install helpers ---------------

function install_script {
    script_name="$1"

    chmod +x $script_name

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # LINUX
        cp $script_name $LINUX_PATH_FOLDER/

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # MAC OS
        cp $script_name $MAC_PATH_FOLDER/
    else
        log_error "unsupported os: ($OSTYPE) !!!"
        exit 1
    fi
}
export -f install_script

# This function will try to install the script. If it does fail, it'll try with sudo
function force_install_script {
    script_name="$1"

    chmod +x $script_name

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # LINUX
        if ! `cp $script_name $LINUX_PATH_FOLDER/`; then
            log_info "Forcing install with sudo"
            sudo cp $script_name $LINUX_PATH_FOLDER
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # MAC OS
        if ! `cp $script_name $MAC_PATH_FOLDER/`; then
            log_info "Forcing install with sudo"
            sudo cp $script_name $MAC_PATH_FOLDER
        fi
    else
        log_error "unsupported os: ($OSTYPE) !!!"
        exit 1
    fi
}
export -f force_install_script

# --------------- validation helpers --------------- 

function is_script_installed {
    script_name="$1"

    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # LINUX
        [[ -f "$LINUX_PATH_FOLDER/$script_name" ]] && return 0 || return 1

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # MAC OS
        [[ -f "$MAC_PATH_FOLDER/$script_name" ]] && return 0 || return 1
    else
        log_error "unsupported os: ($OSTYPE) !!!"
        exit 1
    fi
}
export -f is_script_installed


function is_callable_from_path {
    script_name="$1"
    set +e
    type $script_name > /dev/null 2>&1
    is_installed=$?
    set -e
    return $is_installed
}
export -f is_callable_from_path


# --------------- architecture helpers ---------------

function is_apple_silicon {
    if [[ `uname -m` == 'arm64' ]]; then
        return 0
    fi
    return 1
}
export -f is_apple_silicon

# --------------- key-value config helpers ---------------


function key_value_add {
    key="$1"
    value="$2"
    echo "$value" >> "$CONFIG_KEY_VALUE_FOLDER/$key"    
}
export -f key_value_add


function key_value_delete {
    key="$1"
    rm -f "$CONFIG_KEY_VALUE_FOLDER/$key"    
}
export -f key_value_delete

function key_value_get {
    key="$1"  
    if [ -f "$CONFIG_KEY_VALUE_FOLDER/$key" ];then 
        head -n1 "$CONFIG_KEY_VALUE_FOLDER/$key"  
    else 
        echo -e "" 
    fi      
}
export -f key_value_get


function key_value_list {
    if [ $(ls $CONFIG_KEY_VALUE_FOLDER | wc -l) -eq 0 ];then 
        echo -e "$EMPTY"
    else 
        export -f key_value_get
        ls $CONFIG_KEY_VALUE_FOLDER | xargs -n1 -L1 bash -c 'echo -e "$0 \t\t-> $(key_value_get $0)"'  
    fi      
}
export -f key_value_list


function key_value_reset {
    key="$1"
    rm -f $CONFIG_KEY_VALUE_FOLDER/*   
}
export -f key_value_reset


# --------------- GUI helpers ---------------

function gui_print_welcome {
    echo -e "" && cat ./assets/welcome_ascii && echo -e "${normal}"
}


function gui_ask_option_from_source {
    export __LAST_SELECTED_MENU_OPTION__=""
    source="$1"
    message="$2"   

    # print options
    echo -e "------------------------------------------------------------"
    echo -e "$message"
    echo -e "------------------------------------------------------------"
    source="$1"
    IFS=$'\n'
    index=1
    for item in $(eval $source); do 
        echo -e "$index) - $item"
        index=$((index + 1))
    done
    echo -e "------------------------------------------------------------"

    # ask for option
    item_count=$(eval $source | wc -l)
     
    response=""
    while [[ $response = "" ]]; do
        read -p "$message (Ctrl^C to exit) ?: " raw_response </dev/tty
        response=$(echo "$raw_response" | tr '[:upper:]' '[:lower:]')

        re='^[0-9]+$'
        if ! [[ $response =~ $re ]] ; then
            # not a number
            response=""
        elif [ $response -gt $item_count ] || [ $response -lt 1 ]; then 
            # out of range option
            response=""
        fi

    done
    
    # "return"
    export __LAST_SELECTED_MENU_OPTION__="$response"
}

function gui_get_option_by_index {
    source="$1"
    option=$2
    IFS=$'\n'
    index=1
    for item in $(eval $source); do         
        if [ "$index" = "$option" ]; then
            echo "$item"
        fi
        index=$((index + 1))
    done
    echo ""
}

# --------------- browser helpers ---------------

function browser_open_url {
    url="$1"
    nohup python -m webbrowser "$url" > /dev/null 2>&1
}

# --------------- flags helpers ---------------

function flags_create_tmp {
    flag_name="$1"
    flag="/tmp/dume-$flag_name.flag"
    touch $flag
}

function flags_exists {
    flag_name="$1"
    flag="/tmp/dume-$flag_name.flag"
    if [ -f "$flag" ];then 
        return 0
    else
        return 1
    fi
}

function flags_remove_all {    
    rm "/tmp/dume-*flag"
}