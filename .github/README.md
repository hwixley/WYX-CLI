# ⚡️ WIX CLI ⚡️
Optimize your development productivity in the terminal

<hr>

[![CODEQL](https://github.com/hwixley/wix-cli/actions/workflows/github-code-scanning/codeql/badge.svg)](https://hwixley.github.io/wix-cli/) [![GITHUB_PAGES](https://github.com/hwixley/wix-cli/actions/workflows/pages/pages-build-deployment/badge.svg)](https://hwixley.github.io/wix-cli/) ![License](https://img.shields.io/badge/License-MIT-purple?labelColor=gray&style=flat) ![Version](https://img.shields.io/badge/Version-1.0.0-blue?labelColor=gray&style=flat) ![Platforms](https://img.shields.io/badge/Platforms-BASH%20&%20ZSH-orange?labelColor=gray&style=flat)
<hr>

![wix-terminal](https://user-images.githubusercontent.com/57837950/233463510-d7bf606c-d0a9-45d6-902f-ce0df53862a7.png)

<hr>

## Table of Contents

- [⚡️ WIX CLI ⚡️](#️-wix-cli-️)
  - [Table of Contents](#table-of-contents)
  - [What It Does](#what-it-does)
    - [Why It Was Made](#why-it-was-made)
  - [Dependencies](#dependencies)
  - [Installation](#installation)
  - [Extra Feature Setup](#extra-feature-setup)
  - [Factory-reset Installation](#factory-reset-installation)
  - [List of Commands](#list-of-commands)
      - [Defaults](#defaults)
    - [Navigation](#navigation)
    - [Pseudo-random String Generation](#pseudo-random-string-generation)
    - [Code Editing](#code-editing)
    - [Custom Script/Environment Execution](#custom-scriptenvironment-execution)
    - [Git Automation](#git-automation)
    - [Quick-access URLs](#quick-access-urls)
    - [Data for Custom Scripting Logic](#data-for-custom-scripting-logic)
    - [Editing Data for Custom Scripting Logic](#editing-data-for-custom-scripting-logic)
    - [File Utilities](#file-utilities)
    - [Other Utilities](#other-utilities)
  - [Bugs, New Features, \& Questions](#bugs-new-features--questions)
  - [Make A Contribution](#make-a-contribution)
  - [Support This Project](#support-this-project)

<hr>

## What It Does

Provides developers with the ability for optimising the execution of commonly performed tasks, commands, directory navigations, and environment setups/script executions.

### Why It Was Made

I found myself executing the same commands repeatedly, finding navigation on the terminal for frequently accessed locations needlessly slow, and the task of pushing out new code via manually submitting a PR on my browser repetitive and time-wasting. I decided to start developing my own bash script to help alleviate these issues, and realized the whole world of opportunity I had to help optimize my own daily workflows on the terminal.

I knew I was not the only one who had suffered from these productivity issues as my co-workers saw interest in the tool I was developing. Upon this I decided to start developing a more generic and robust version of my original tool to allow developers across the world optimize their productivity with this tool too!

<hr>

## Dependencies

<ins>The dependencies include:</ins>
- `openssl` for the [Pseudo-random String Generation](https://github.com/hwixley/wix-cli#pseudo-random-string-generation) commands.
- `git` for all [Git Automation](https://github.com/hwixley/wix-cli#git-automation) commands.
- Visual Studio Code for the `vsc` code editor command.
- XCode for the `xc` code editor command (only available for Macintosh systems).
- `speedtest` (the Ookla speedtest-cli) for runnning network speed tests. The installation commands for this on MacOS and Debian are in `setup.sh`.

<hr>

## Installation

1. Clone this repository into a folder of your choice: 
```
git clone git@github.com:hwixley/WIX-CLI.git
```
2. Navigate into the directory:
```
cd WIX-CLI
```
3. Give permissions to the setup script and run it:
```
chmod +x setup.sh && ./setup.sh
```
4. Reopen your terminal or run `source ~/.bashrc` (`source ~/.zshrc` for unix systems)

Type `wix` to see the list of commands and start developing some magic!

## Extra Feature Setup

1. You can use OpenAI's ChatGPT to write commit messages for you (using `git diff` and `git status` outputs) when using the `wix push` command. <i>This requires an OpenAI API key.</i>
```
wix setup smart_commit
```
## Factory-reset Installation

1. Remove your installation
```
rm -rf <path-of-installation>
```
1. Remove the wix-cli script setup in your environment file
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
2. Follow the [installation instructions](https://github.com/hwixley/wix-cli#installation)

<hr>

## List of Commands

Please note any command with an argument in angle brackets below (ie. `<branch>`) denotes a dynamic variable which is given by the user. If the text inside these angle has a `?` character at the end (ie. `<branch?>`) this denotes that this argument is optional and if left empty will fallback to the default.

#### Defaults
- `<branch?>` : if left empty the current branch will be used
- `<org?>` : if left empty the default GitHub organisation set in `myorgs` will be used
- Any other optional arguments that you omit will be prompted upon execution

<br>

<i>**\*\*Note: all commands below should be preceded by the `wix` command, this was ommitted for readability.\*\***</i>
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
4. `nb <name?>`: create a new branch
5. `pr`: create a PR against the default branch from the current branch
6. `bpr <name?>`: checkout changes to a new branch and create a PR from this branch
7. `setup smart_commit`: this allows you to use OpenAI's ChatGPT to write commit messages for you (using `git diff` and `git status` outputs). <i>This requires an OpenAI API key.<i>

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
1. `editd <data>`: allows the user to edit the specified piece of data (`user`, `myorgs`, `mydirs`, `myscripts`, or `todo`)
2. `edits <myscript>`: allows the user to edit the specified script (this edits the script referenced from the alias stored in `myscripts` not the `myscripts` aliases data)
3. `newscript <script-name?>`: allows the user to create a new script

### File Utilities
1. `fopen`: open the current directory in your native files application
2. `find <fname>.<fext>`: find a file inside the current directory with the respective name (use `find "*.<ext>"` for finding all files with the given extension)
3. `regex <regex?> <fname?>`: counts number of regex matches found in the given file
4. `rgxmatch <regex?> <fname?>`: returns strings of regex matches found in the given file

### Other Utilities
1. `ip`: get local and public IP addresses of your computer
2. `genqr <url?> <fname?>`: generate a png QR code for the specified URL
3. `wifi`: lists details about available wifi networks on your host machine
4. `wpass`: lists your saved wifi passwords
5. `speedtest`: run a network speedtest
6. `copy <string?|cmd?>`: copy a string or the output of a shell command (using $(<cmd>) syntax) to your clipboard

<hr>

## Bugs, New Features, & Questions

Please post bug reports and new features in the issues section - there are custom templates you can use for each of these. And please post any questions you may have in the discussion section, I will reply to these as soon as I can! :)

<hr>

## Make A Contribution

Contributions are welcome! Pick up a ticket from the Issues section and link it in your PR, I will review it when I can!

<hr>

## Support This Project

I am developing this project in my spare time to help developer's across the globe maximize their productivity in the terminal. If you have found this tool useful please leave a star on this repository it really helps me out! I also have a [buymeacoffee](https://www.buymeacoffee.com/hwixley) sponsor link if you would like to help me to continue to be able to develop OSS in spare time by helping me stay caffeinated and coding. :coffee: :zap:
