# WIX CLI: optimize your development productivity in the terminal
[![PAGES](https://badgen.net/badge/Github%20Pages/active/green)](https://hwixley.github.io/wix-cli/)
[![LICENSE](https://badgen.net/badge/License/MIT/purple)](https://github.com/hwixley/wix-cli/blob/master/LICENSE.md)
[![VERSION](https://badgen.net/badge/Version/0.0.0.0/blue)](https://github.com/hwixley/wix-cli)

<hr>

## Table of Contents

1. [Support](https://github.com/hwixley/wix-cli#support)
2. [What it does?](https://github.com/hwixley/wix-cli#what-it-does)
3. [Customisation](https://github.com/hwixley/wix-cli#customisation)
4. [Dependencies](https://github.com/hwixley/wix-cli#dependencies)
5. [Installation](https://github.com/hwixley/wix-cli#installation)
6. [List of Commands](https://github.com/hwixley/wix-cli#list-of-commands)

<hr>

## Support

Supports unix and linux kernels with `.zshrc` or `.bashrc` environment files.

## What it does?

Provides developers with the ability for optimising the usage of commonly used commands, directories, environments, and scripts.

## Customisation

<hr>

## Dependencies

<ins>The main dependencies include:</ins> `openssl` and `git`.

<ins>The code editor dependencies include:</ins> `VScode` and `Xcode` (for mac systems), however, only the `vsc` and `xc` commands depend on these.

## Installation

1. Clone this repository into a folder of your choice: 
```
git clone git@github.com:hwixley/wix-cli.git
```
2. Give permissions to the setup script and run it:
```
chmod +x setup.sh && ./setup.sh
```

Type `wix` to see the list of commands and start developing some magic!

<hr>

## List of Commands

Please note any command with an argument in angle brackets below (ie. `<branch>`) denotes a dynamic variable which is given by the user. If the text inside these angle has a `?` character at the end (ie. `<branch?>`) this denotes that this argument is optional and if left empty will fallback to the default.

#### Defaults:
- `<branch?>` : if left empty the current branch will be used
- `<org?>` : if left empty the default GitHub organisation set in `myorgs` will be used


**Note: all commands below should be preceded by the `wix` command, this was ommitted to prevent redundancy.**


### General Utility
1. `cd <mydir>`: directory navigation using custom aliases stores in `mydirs`
2. `back`: go back to last directory
3. `genpass`: generate and copy random 16-bit hex password

### Directory Management
1. `new <mydir> <subdir>`: create new directory in location of alias
2. `delete <mydir> <subdir>`: delete directory in location of alias
3. `hide <mydir> <subdir>`: hide directory in location of alias

### Code Editing
1. `vsc <mydir>`: open location of alias in Visual Studio Code
2. `xc <mydir>`: open location of alias in XCode (only available for macintosh systems)

### Custom Script/Environment Execution
1. `run <myscript>`: setup and run the script saved under the given script alias

### Git Automation
1. `push <branch?>`: push changes to the given repository branch (prompts you to enter a commit message on execution and leaves a default message if left empty)
2. `pull <branch?>`: pull changes from the given repository branch
3. `ginit <org?> <repo>`: initialize git repository in current directory under the specified organization (`<org?>` - the default user is used as the owner if left empty) and with the specified name (`<repo>`)
4. 

### Quick-access URLs
1. `repo`: go to the respective GitHub repository url on the default branch from your current directory
2. `branch`: go to the respective GitHub repository url on the current branch from your current directory
3. `profile`: go to your GitHub profile
4. `org <org?>`: go to the specified url of the GitHub organization
5. `help`: go to the wix-cli GitHub Pages url for documentation

### Customisable Data for Custom Scripting Logic
1. `user`
2. `myorgs`
3. `mydirs`
4. `myscripts`
5. `editd <data>`
6. `edits <myscript>`