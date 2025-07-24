# Contributing to this project
We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We Develop with Github
We use github to host code, to track issues and feature requests, as well as accept pull requests.

### All Code Changes Happen Through Pull Requests
Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `master`.
2. If you've changed APIs, update the documentation.
3. Make sure your code is well formatted.
4. Issue that pull request!

## Report bugs using Github's [issues](https://github.com/cjpablo92/dume/issues)
We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/cjpablo92/dume/issues/new); it's that easy!

## Write bug reports with detail, background, and sample code
[This is an example](http://stackoverflow.com/q/12488905/180626) of a bug report well written.

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can. Include sample code that *anyone* can run to reproduce the bug.
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

People *love* thorough bug reports. I'm not even kidding.

## How to add a new installation script

To create a new installation script you need to run the following command:
* ```dume -n <name of the script>```
* Or locally: ```./setup.sh -n <name of the script>```

It will automatically create a new file under de ./scripts/install path with the following content:

```sh
#!/bin/bash
set -e

# Get script directory for proper path resolution
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")/../.." && pwd)"

source "$SCRIPT_DIR/libs/logger.sh"
source "$SCRIPT_DIR/libs/conf_manager.sh"

log_info "installing {{NAME}}..."

if is_callable_from_path "{{NAME}}"; then 
    log_info "\t{{NAME}} already installed"
else 
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # LINUX
        log_error "IMPLEMENT THIS FOR LINUX !!!"
        exit 1
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # MAC OS
        log_error "IMPLEMENT THIS FOR MAC !!!"
        exit 1
    else
        log_error "unsupported os: ($OSTYPE) !!!"
        exit 1
    fi
fi

log_info "installing {{NAME}}...DONE!"
```

{{NAME}} will be replaced with the name of the script you are creating and in there you just have to code the following sections:

**For linux** 
```sh
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # LINUX
        log_error "IMPLEMENT THIS FOR LINUX !!!"
        exit 1
```

**For Mac OS**
```sh
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # MAC OS
        log_error "IMPLEMENT THIS FOR MAC !!!"
        exit 1
``` 

***For Mac OS apple silicon***
Also for Mac OS with applie silicon we have a helper that you can import from `source ./libs/conf_manager.sh`
```sh
if is_apple_silicon; then
    # Do specifics on MAC OS apple silicon
fi
```

_NOTE: Check `./libs/conf_manager.sh` and the `./libs/logger.sh` files for more utility functions_

## Testing Your Changes

When contributing, make sure to test your changes in both environments:

### Local Testing
```bash
./setup.sh -n test_script  # Create a test script
./setup.sh -p your_profile # Test your profile locally
```

### Global Testing
```bash
dume -n test_script        # Test script creation globally
dume -p your_profile       # Test your profile globally
```

Always ensure your scripts work correctly when run via the global symlink, as paths are resolved differently.

## How to add a new profile

Just create a file inside the `/profiles/` directory with all the things you want to install. (See the available installation scripts by running `dume -ls` or `dume --list-scripts`)

### Profile Dependencies

You can include other profiles in your profile using the `#include-profile` directive:

```
#include-profile:default
aws
docker
kubectl
```

This will install everything from the `default` profile plus the additional tools listed.

## How to make a profile automatically add env vars to my local environment

Just create a file inside the `/env/` directory with all the env vars you want to copy to the local environment, you have to provide the key value pair (ENV=value). (See an example inside the folder `/env/architecture`)

## How to make a profile to clone github repositories automatically

Just create a file inside the `/github/` directory with all the repos you want to clone from github, you just need to provide the URI, not the full path of the repo. (See an example inside the folder `/github/architecture`)
