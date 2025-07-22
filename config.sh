#!/bin/bash
source ./libs/logger.sh
source ./libs/conf_manager.sh


function print_usage {
    echo "${bold}NAME${normal}"
    echo -e "\tconfig.sh - Config helper"
    echo ""

    echo "${bold}SYNOPSIS${normal}"
    echo -e "\tconfig.sh OPTION..."
    echo ""

    echo "${bold}DESCRIPTION${normal}"
    echo -e "\t-h, --help"
    echo -e "\t\tprint usage"
    echo ""
    echo -e "\t\te.g.: ./setup -h"
    echo -e "\t\te.g.: ./setup --help"
    echo ""

    echo -e "\t-a, --add <key> <value>"
    echo -e "\t\tadd entries"
    echo ""

    echo -e "\t-g, --get <key>"
    echo -e "\t\tget entry by key"
    echo ""

    echo -e "\t-d, --delete <key>"
    echo -e "\t\tdelete entry by key"
    echo ""

    echo -e "\t-r, --reset <key>"
    echo -e "\t\tdelete all config"
    echo ""

    echo -e "\t-l, --list"
    echo -e "\t\tprint config entries"
    echo ""

    echo -e "\t\te.g.: ./config.sh -l"
	exit 0
}


function menu {
    profile=""
    
    if [ -z "$1" ]; then    
        print_usage
    else 
        while test $# -gt 0
        do
            case "$1" in      
                -h| --help) 
                    print_usage             
                    ;;      
                -l| --list) 
                    key_value_list            
                    ;;     
                -a| --add) 
                    key="$2"
                    value="$3"

                    if [ -z "$value" ]; then
                        print_usage
                        exit 0
                    else 
                        shift
                        shift
                    fi

                    key_value_add $key $value

                    shift
                    ;;     
                -g| --get) 
                    key="$2"
     
                    if [ -z "$key" ]; then
                        print_usage
                        exit 0
                    else                         
                        shift
                    fi

                    key_value_get $key

                    shift
                    ;;
                -d| --delete) 
                    key="$2"
     
                    if [ -z "$key" ]; then
                        print_usage
                        exit 0
                    else                         
                        shift
                    fi

                    key_value_delete $key
                    flags_remove_all

                    shift
                    ;;
                -r| --reset) 
                    read -p "You are about to remove all installation preferences (Enter to continue, Ctrl^C to quit) ..."
                    key_value_reset
                    ;;   
                   
            esac
            shift
        done

    fi   
}

menu $@
