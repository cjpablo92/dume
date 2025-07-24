#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
source "$SCRIPT_DIR/libs/logger.sh"
source "$SCRIPT_DIR/libs/conf_manager.sh"

gui_print_welcome


function print_usage {
    echo "${bold}NAME${normal}"
    echo -e "\tdume - Settup dev environment"
    echo ""

    echo "${bold}SYNOPSIS${normal}"
    echo -e "\tdume OPTION..."
    echo ""

    echo "${bold}DESCRIPTION${normal}"
    echo -e "\t-h, --help"
    echo -e "\t\tprint usage"
    echo ""
    echo -e "\t\te.g.: dume -h"
    echo -e "\t\te.g.: dume --help"
    echo ""
    echo -e "\t-p, --profile PROFILE (e.g.: backend, custom, ...)"
    echo -e "\t\tinstall features acording to the role"
    echo -e "\t\t(you can see the full list with the -lp option)"
    echo ""
    echo -e "\t\te.g.: dume -p backend"
    echo ""
    echo -e "\t-v, --verbose"
    echo -e "\t\tverbose mode on"
    echo ""
    echo -e "\t\te.g.: dume -p backend -v"
    echo -e "\t\te.g.: dume --profile backend -v"
    echo -e "\t\te.g.: dume --profile backend --verbose"
    echo ""
    echo -e "\t-lp, --list-profiles"
    echo -e "\t\tsee all available profiles"
    echo ""
    echo -e "\t\te.g.: dume -lp"
    echo -e "\t\te.g.: dume --list-profiles"
    echo ""
    echo -e "\t-dp, --describe-profile PROFILE (e.g.: backend, custom, ...)"
    echo -e "\t\tsee all installation scripts in a profile"
    echo ""
    echo -e "\t\te.g.: dume -dp backend"
    echo -e "\t\te.g.: dume --describe-profile backend"
    echo ""
    echo -e "\t-ls, --list-scripts"
    echo -e "\t\tsee all available scripts"
    echo ""
    echo -e "\t\te.g.: dume -ls"
    echo -e "\t\te.g.: dume --list-scripts"
    echo ""
    echo -e "\t-n, --new SCRIPT_NAME (e.g.: nmap, ...)"
    echo -e "\t\tcreate a new installation script"
    echo ""
    echo -e "\t\te.g.: dume -n my_installation_script"
    echo -e "\t\te.g.: dume --new my_installation_script"
    echo ""
    exit 1
}

function print_profiles {
    print_title "${bold}AVAILABLE PROFILES${normal}"
    ls "$SCRIPT_DIR/profiles" | sort
}

function print_installables {
    print_title "${bold}AVAILABLE INSTALLABLES${normal}"
    ls "$SCRIPT_DIR/scripts/install" | sort
}

function print_scripts {
    print_title "${bold}AVAILABLE SCRIPTS${normal}"
    ls "$SCRIPT_DIR/scripts/custom" | sort
    echo ""
    print_installables
    echo ""
}

function check_param {
    first_letter=$(echo "$1" | grep -o "^." )
    if [ "$first_letter" == "-" ];then 
        print_usage
    fi

    if [ -z "$1" ]; then
        print_usage
    fi
}

function check_profile {
    # check profile
    check_param $1

    if [[ "$1" == "custom" ]]; then
        ls "$SCRIPT_DIR/scripts/install" | sort >> "$SCRIPT_DIR/profiles/custom"
        vi "$SCRIPT_DIR/profiles/custom"
    fi

    # check existence 
    if [ ! -f "$SCRIPT_DIR/profiles/$1" ];then 
        echo -e "invalid profile: \"$1\" (check -h option for help)"                        
        exit 1
    fi
}

function menu {
    profile=""
    
    if [ -z "$1" ]; then    
        print_usage
    else 
        while test $# -gt 0
        do
            case "$1" in    
                -p| --profile) 
                    profile="$2"
                    check_profile $profile
                    shift
                    ;;    
                -n| --new) 
                    script_to_create="$2"
                    check_param $script_to_create
                    shift

                    # TODO - FIXME 
                    cat "$SCRIPT_DIR/scripts/__template__.sh" | sed s/'{{NAME}}'/"$script_to_create"/g > "$SCRIPT_DIR/scripts/install/$script_to_create"
                    chmod +x "$SCRIPT_DIR/scripts/install/$script_to_create"
                    ;;   
                -h| --help) 
                    print_usage             
                    ;;      
                -v| --verbose) 
                    export VERBOSE=true             
                    ;;
                -lp| --list-profiles) 
                    print_profiles         
                    ;; 
                -dp| --describe-profile) 
                    profile="$2"
                    check_profile $profile
                    print_title "${bold}PROFILE DETAIL${normal}"
                    cat "$SCRIPT_DIR/profiles/$profile"
                    echo ""
                    exit 0
                    ;;
                -li| --list-installables) 
                    print_installables         
                    ;;   
                -ls| --list-scripts) 
                    print_scripts         
                    ;;         
            esac
            shift
        done

    fi
    # echo "PROFILE: $profile"
    if [ "$profile" = "" ]; then
        log_warn "no profile selected"
        # ls scripts | sort | xargs -n1 bash -c './scripts/$0'
        # ls scripts | sort | xargs -n1 bash -c './scripts/$0.sh'
    else 
        # pre-cond-install
        log_info "----> Installing pre conditions ..."
        ls "$SCRIPT_DIR/scripts/pre_cond_install" | xargs -n1 bash -c '"$SCRIPT_DIR/scripts/pre_cond_install/$0"'
        log_info "----> Installing pre conditions ... DONE!"
        echo ""

        # ----- install -----
        log_info "----> Installing ..."

        # (for included profiles scripts)
        includes_count=$(cat "$SCRIPT_DIR/profiles/$profile" | grep '#include-profile' | wc -l)
        if [ $includes_count -gt 0 ];then
            for include_profile in $(cat "$SCRIPT_DIR/profiles/$profile" | grep '#include-profile' | cut -d: -f2); do 
                # log_info "\t [installing included profile] - $include_profile ..."

                    # check existence 
                    if [ ! -f "$SCRIPT_DIR/profiles/$include_profile" ];then 
                        log_error "invalid include profile: \"$include_profile\" (check parent profile: $profile)"                        
                        exit 1
                    fi

                cat "$SCRIPT_DIR/profiles/$include_profile" | grep -v '#include-profile' | sort | xargs -n1 bash -c '"$SCRIPT_DIR/scripts/install/$0"'

                # log_info "\t [installing included profile] - $include_profile ... DONE!"
            done
        fi

        # (for own scripts)
        cat "$SCRIPT_DIR/profiles/$profile" | grep -v '#include-profile' | sort | xargs -n1 bash -c '"$SCRIPT_DIR/scripts/install/$0"'
        log_info "----> Installing ... DONE!"
        echo ""
        
        # ------ post-install ----- (if post install scripts is contained inside the profile set)
        print_title "Post install actions"
        echo ""

        # (for included profiles scripts)
        includes_count=$(cat "$SCRIPT_DIR/profiles/$profile" | grep '#include-profile' | wc -l)
        if [ $includes_count -gt 0 ]; then
            for include_profile in $(cat "$SCRIPT_DIR/profiles/$profile" | grep '#include-profile' | cut -d: -f2); do 
                ls "$SCRIPT_DIR/scripts/post_install" | xargs -n1 -L1 bash -c 'grep $0 -o "$SCRIPT_DIR/profiles/'$include_profile'"' | xargs -n1 -L1 bash -c '[[ -f "$SCRIPT_DIR/scripts/post_install/$0" ]] && "$SCRIPT_DIR/scripts/post_install/$0"; echo ""'
            done
        fi

        # (for specific scripts)        
        ls "$SCRIPT_DIR/scripts/post_install" | xargs -n1 -L1 bash -c 'grep $0 -o "$SCRIPT_DIR/profiles/'$profile'"' | xargs -n1 -L1 bash -c '[[ -f "$SCRIPT_DIR/scripts/post_install/$0" ]] && "$SCRIPT_DIR/scripts/post_install/$0"; echo ""'

        # (for "cond" scripts)
        ls "$SCRIPT_DIR/scripts/post_cond_install" | xargs -n1 bash -c '"$SCRIPT_DIR/scripts/post_cond_install/$0"; echo ""'
        log_info "----> Post install actions ... DONE!"

        # ----- install custom scripts -----
        log_info "----> Installing custom scripts ..."
        ls "$SCRIPT_DIR/scripts/custom" | xargs -n1 -L1 bash -c 'force_install_script "$SCRIPT_DIR/scripts/custom/$0"'
        log_info "----> Installing custom scripts ... DONE!"
        echo ""

        # Copy env vars
        log_info "----> Copying ENV VARS ..."
        if [ -f "$HOME/.zshrc" ];then 
            log_info "Copying env vars to .zshrc"
            cat "$SCRIPT_DIR/env/$profile" >> "$HOME/.zshrc"
        else
            if [ ! -f "$HOME/.bashrc" ];then 
                log_info ".bashrc not found creating the file"
                touch "$HOME/.bashrc"
                log_info ".bashrc created"
            fi
            log_info "Copying env vars to .bashrc"
            cat "$SCRIPT_DIR/env/$profile" >> "$HOME/.bashrc"
        fi
        log_info "----> Copying ENV VARS ...DONE!"
        echo ""
        
        # Clone Github repositories
        log_info "----> Creating Github working dir ..."
        log_info "Creating directory... $HOME/github"
        mkdir -p "$HOME/github"
        log_info "----> Creating Github working dir ... DONE!"
        log_info "----> Cloning Github repositories ..."
        if [ -f "$SCRIPT_DIR/github/$profile" ];then 
            cat "$SCRIPT_DIR/github/$profile" | sort | xargs -n1 bash -c 'git clone https://github.com/$0 $HOME/github/$0'
        else
            log_info "No repos to clone skipping step"
        fi
        log_info "----> Cloning Github repositories ... DONE!"
        echo ""

    fi

}

menu $@
