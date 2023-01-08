# WIX CLI: optimize your development productivity in the terminal
[![GITHUB_PAGES](https://github.com/hwixley/wix-cli/actions/workflows/pages/pages-build-deployment/badge.svg)](https://hwixley.github.io/wix-cli/)
[![LICENSE](https://badgen.net/badge/License/MIT/purple)](https://github.com/hwixley/wix-cli/blob/master/LICENSE.md)
[![VERSION](https://badgen.net/badge/Version/0.0.0/blue)](https://github.com/hwixley/wix-cli)
[![PLATFORMS](https://badgen.net/badge/Platforms/bash%20%26%20zsh/orange)](https://github.com/hwixley/wix-cli)

<hr>

## Table of Contents

1. [What It Does](#what-it-does)
2. [Why It Was Made](#why-it-was-made)
3. [Bugs, New Features, & Questions](#bugs-new-features--questions)
4. [Support This Project](#support-this-project)
5. [Dependencies](#dependencies)
6. [Installation](#installation)
7. [Factory-reset Installation](#factory-reset-installation)
8. [List of Commands](#list-of-commands)

<hr>

![wix-terminal](https://user-images.githubusercontent.com/57837950/211174801-e3294f52-0765-4fe1-bd34-db6ca2cf7763.png)

<hr>

## What It Does

Provides developers with the ability for optimising the execution of commonly performed tasks, commands, directory navigations, and environment setups/script executions.

## Why It Was Made

I found myself executing the same commands repeatedly, finding navigation on the terminal for frequently accessed locations needlessly slow, and the task of pushing out new code via manually submitting a PR on my browser repetitive and time-wasting. I decided to start developing my own bash script to help alleviate these issues, and realized the whole world of opportunity I had to help optimize my own daily workflows on the terminal.

I knew I was not the only one who had suffered from these productivity issues as my co-workers saw interest in the tool I was developing. Upon this I decided to start developing a more generic and robust version of my original tool to allow developers across the world optimize their productivity with this tool too!

<hr>

## Bugs, New Features, & Questions

Please post bug reports and new features in the issues section - there are custom templates you can use for each of these. And please post any questions you may have in the discussion section, I will reply to these as soon as I can! :)

<hr>

## Support This Project

I am developing this project in my spare time to help developer's across the globe maximize their productivity in the terminal. If you have found this tool useful please leave a star on this repository it really helps me out! I also have a buymeacoffee sponsor link if you would like to help me to continue to be able to develop OSS in spare time by helping me stay caffeinated and coding. :)

<hr>

## Dependencies

<ins>The dependencies include:</ins>
- `openssl` for the [Pseudo-random String Generation](https://github.com/hwixley/wix-cli#pseudo-random-string-generation) commands.
- `git` for all [Git Automation](https://github.com/hwixley/wix-cli#git-automation) commands.
- Visual Studio Code for the `vsc` code editor command.
- XCode for the `xc` code editor command (only available for Macintosh systems).

## Installation

1. Clone this repository into a folder of your choice: 
```
git clone git@github.com:hwixley/wix-cli.git
```
2. Give permissions to the setup script and run it:
```
chmod +x setup.sh && ./setup.sh
```
3. Reopen your terminal or run `source ~/.bashrc` (`~/.zshrc` for unix systems)

Type `wix` to see the list of commands and start developing some magic!

## Factory-reset Installation

1. Remove your installation
```
rm -rf <path-of-installation>
```
2. Remove the wix-cli script setup in your environment file
    - Open the file in an editor: (`~/.bashrc` for linux systems, and `~/.zshrc` for unix systems) 
        ```
        gedit ~/.bashrc
        ```
        If `gedit` is not available you can always use vim instead:
        ```
        vi ~/.bashrc
        ```
    - Remove the 2 lines for the wix-cli:<br>
        - The first line is a comment: `# WIX-CLI`<br>
        - The second line is where the command is actually setup: `alias wix="<path-of-installation>/wix-cli.sh"`
3. Follow the [installation instructions](https://github.com/hwixley/wix-cli#installation)

<hr>

## List of Commands

Please note any command with an argument in angle brackets below (ie. `<branch>`) denotes a dynamic variable which is given by the user. If the text inside these angle has a `?` character at the end (ie. `<branch?>`) this denotes that this argument is optional and if left empty will fallback to the default.

#### Defaults:
- `<branch?>` : if left empty the current branch will be used
- `<org?>` : if left empty the default GitHub organisation set in `myorgs` will be used

<br>

**<ins>Note:</ins> all commands below should be preceded by the `wix` command, this was ommitted to prevent redundancy and promote readability.**

<br>

### Navigation
1. `cd <mydir>`: directory navigation using custom aliases stored in `mydirs`
2. `back`: go back to last directory

### Pseudo-random String Generation
3. `genhex <hex-length?>`: generate and copy pseudo-random hex string of specified length (of default length 32)
3. `genb64 <base64-length?>`: generate and copy pseudo-random base64 string of specified length (of default length 32)

<!-- ### Directory Management
1. `new <mydir> <subdir>`: create new directory in location of alias
2. `delete <mydir> <subdir>`: delete directory in location of alias
3. `hide <mydir> <subdir>`: hide directory in location of alias -->

### Code Editing
1. `vsc <mydir>`: open location of alias in Visual Studio Code
2. `xc <mydir>`: open location of alias in XCode (only available for macintosh systems)

### Custom Script/Environment Execution
1. `run <myscript>`: setup and run the script saved under the given script alias

### Git Automation
1. `push <branch?>`: push changes to the given repository branch (prompts you to enter a commit message on execution and leaves a default message if left empty)
2. `pull <branch?>`: pull changes from the given repository branch
3. `ginit <newdir?>`: initialize git repository in current directory if `<newdir>` is not set, otherwise, a new directory is created called `<newdir>` and a git repository is initialized there instead
<!-- 4. `gnew <mydir/org> <repo>`: create and initialize a new directory as a git repository -->
5. `nbranch <name?>`: create a new branch
6. `pr`: create a PR against the default branch from the current branch
7. `bpr`: checkout changes to a new branch and create a PR from this branch

### Quick-access URLs
1. `repo`: go to the respective GitHub repository url on the default branch from your current directory
2. `branch`: go to the respective GitHub repository url on the current branch from your current directory
3. `profile`: go to your GitHub profile
4. `org <myorg?>`: go to the specified url of the GitHub organization
5. `help`: go to the wix-cli GitHub Pages url for documentation

### Data for Custom Scripting Logic
1. `user`: displays stored user-specific data such as: `username` - which represents the user's GitHub username (for configuring GitHub urls), `name`  - for software licensing copyright clauses (when setting up GitHub software licenses for your repositories)
2. `myorgs`: displays stored aliases for user's GitHub organizations (for configuring GitHub urls). Please note you can use the `default` alias for your most commonly used organization, allowing you to not have to type the organization alias in cases where a `<myorg?>` argument is present
3. `mydirs`: displays stored aliases for user's directories (for efficient terminal navigation)
4. `myscripts`: displays stored aliases for user's custom scripts (for efficient environment setup or script execution)

### Editing Data for Custom Scripting Logic
1. `editd <data>`: allows the user to edit the specified piece of data (`user`, `myorgs`, `mydirs` or `myscripts`)
2. `edits <myscript>`: allows the user to edit the specified script (this edits the script referenced from the alias stored in `myscripts` not the `myscripts` aliases data)
