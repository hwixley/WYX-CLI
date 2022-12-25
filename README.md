# WIX CLI: optimize your development productivity in the terminal
[![PAGES](https://badgen.net/badge/Github%20Pages/active/green)](https://hwixley.github.io/wix-cli/)
[![LICENSE](https://badgen.net/badge/License/MIT/purple)](https://github.com/hwixley/wix-cli/blob/master/LICENSE.md)
[![VERSION](https://badgen.net/badge/Version/0.0.0.0/blue)](https://github.com/hwixley/wix-cli)

<hr>

## Table of Contents

1. [Support](https://github.com/hwixley/wix-cli#support)
2. [Creating Issues](https://github.com/hwixley/wix-cli#creating-issues)
2. [What it does](https://github.com/hwixley/wix-cli#what-it-does)
3. [Why it was made](https://github.com/hwixley/wix-cli#why-it-was-made)
4. [Dependencies](https://github.com/hwixley/wix-cli#dependencies)
5. [Installation](https://github.com/hwixley/wix-cli#installation)
6. [List of Commands](https://github.com/hwixley/wix-cli#list-of-commands)

<hr>

## Support

Supports unix and linux kernels with `.zshrc` or `.bashrc` environment files.

## Creating Issues

Please mark the title of your issues with the appropriate prefix (as listed below) so it is obvious the reason for your issue:
- `[BUG]`: for submitting a bug report
- `[QUESTION]`: for asking a question about the tool
- `[NEW-FEATURE]`: for proposing new features to add to the tool

<hr>

## What It Does

Provides developers with the ability for optimising the execution of commonly performed tasks, commands, directory navigations, and environment setups/script executions.

## Why It Was Made

I found myself executing the same commands repeatedly, finding navigation on the terminal for frequently accessed locations needlessly slow, and the task of pushing out new code via manually submitting a PR on my browser needlessly repetitive and time-wasting. I decided to start developing my own bash script to help alleviate these issues, and realized the whole world of opportunity I had to help optimize my own daily workflows on the terminal.

I knew I was not the only one who had suffered from these productivity issues as my co-workers saw interest in the tool I was developing. Upon this I decided to start developing a more generic and robust version of my original tool to allow developers across the world optimize their productivity with this tool too!

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

<br>

**<ins>Note:</ins> all commands below should be preceded by the `wix` command, this was ommitted to prevent redundancy and promote readability.**

<br>

### General Utility
1. `cd <mydir>`: directory navigation using custom aliases stored in `mydirs`
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
4. `gnew <mydir/org> <repo>`: create and initialize a new directory as a git repository
5. `nbranch <name?>`: create a new branch
6. `pr`: create a PR against the default branch from the current branch
7. `bpr`: checkout changes to a new branch and create a PR from this branch

### Quick-access URLs
1. `repo`: go to the respective GitHub repository url on the default branch from your current directory
2. `branch`: go to the respective GitHub repository url on the current branch from your current directory
3. `profile`: go to your GitHub profile
4. `org <org?>`: go to the specified url of the GitHub organization
5. `help`: go to the wix-cli GitHub Pages url for documentation

### Data for Custom Scripting Logic
1. `user`: displays stored user-specific data such as GitHub username (for configuring GitHub urls)
2. `myorgs`: displays stored aliases for user's GitHub organizations (for configuring GitHub urls)
3. `mydirs`: displays stored aliases for user's directories (for efficient terminal navigation)
4. `myscripts`: displays stored aliases for user's custom scripts (for efficient environment setup or script execution)

### Editing Data for Custom Scripting Logic
1. `editd <data>`: allows the user to edit the specified piece of data (`user`, `myorgs`, `mydirs` or `myscripts`)
2. `edits <myscript>`: allows the user to edit the specified script (this edits the script referenced from the alias stored in `myscripts` not the `myscripts` aliases data)