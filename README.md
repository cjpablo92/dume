<h1 align="center">
  <a href="https://github.com/cjpablo92/dume">
  	<img src="https://user-images.githubusercontent.com/17183291/197861377-fafa0c5c-fe12-470f-a308-4f43de859537.png" alt="dume" width="200">
  </a>
  <br>
  <br>
  dum-e
  <br>
</h1>
<h4 align="center">Tool to set up local environment</h4>
<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#dependencies">Dependencies</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#faq">FAQ</a>
</p>

## Key Features

* Install development tools
* Config the environment (SSH keys, SSH tunnel, iterm config)

## Dependencies

* NONE

## How To Use

### Installation

First, make dume available globally on your system:
```bash
./install.sh
```

This creates a symlink in your PATH so you can run `dume` from anywhere.

### Quick Start

View available options:
```bash
dume --help
# or locally: ./setup.sh --help
```

List available profiles:
```bash
dume -lp
```

Install a development environment:
```bash
dume -p fullstack
```

List all available scripts:
```bash
dume -ls
```

### Other Utilities

Manage config:
```bash
./config.sh --help
```

Package the project:
```bash
./package.sh
```

## Documentation
Project structure

```
.
├── assets                    # Assets or static files to use on the project
│   └── welcome_ascii         # Ascii to load as welcome logo
├── env                       # Environment variable files for profiles
│   └── ...
├── github                    # GitHub repository lists for profiles
│   └── ...
├── libs                      # Libraries or utilities to use within the project
│   ├── conf_manager.sh       # Functions to use within the project
│   └── logger.sh             # Logger functions
├── profiles                  # Profile files to store pre-built environments based on the role
│   └── ...                   # Profile list
├── scripts                   # All the available installation scripts stored by stage (pre-install, install, post-install, etc)
│   ├── custom                # This are custom installation utilities (E.G: cheats, etc)
│   │   ├── cheats
│   │   └── ...
│   ├── install               # Contains all the tools installation scripts (E.G: nvm, aws, dbeaver, intellij, etc)
│   │   ├── nvm
│   │   └── ...
│   ├── post_cond_install     # Contains all the scripts that runs post-install actions in general (not tight to any script or profile)
│   ├── post_install          # Contains all the scripts that runs post-install actions on specific installation scripts (E.G: setup intellij credential)
│   ├── pre_cond_install      # Contains all the pre requirements scripts in order for the installation scripts to work
│   │   ├── python
│   │   ├── homebrew
│   │   └── ...
│   └── __template__.sh       # Template to bootstrap a new installable (`dume -n my_cool_installation_script`)
├── config.sh                 # Utility to manage config flags locally (still in beta)
├── CONTRIBUTE.md             # Contribution guide
├── install.sh                # Installation script to make dume globally available
├── package.sh                # Utility to package the app (generate a .gz file)
├── README.md                 # Readme
└── setup.sh                  # Main entry point of the app (`dume -h` or `./setup.sh -h`)
```

## Contribute
If you want to add new features to this project please [see the contribution guide](CONTRIBUTE.md)

_NOTE: Check `./setup.sh --new <script_to_add>` option_
