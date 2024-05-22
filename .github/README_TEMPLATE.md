# ⚡️ WYX CLI ⚡️

Optimize your development productivity in the terminal

<hr>

[![CODEQL](https://github.com/hwixley/wyx-cli/actions/workflows/github-code-scanning/codeql/badge.svg)](https://hwixley.github.io/wyx-cli/) [![Deploy Jekyll GH-Pages](https://github.com/hwixley/WYX-CLI/actions/workflows/jekyll-gh-pages.yml/badge.svg)](https://github.com/hwixley/WYX-CLI/actions/workflows/jekyll-gh-pages.yml) [![Generate Stdout Image](https://github.com/hwixley/WYX-CLI/actions/workflows/main.yml/badge.svg)](https://github.com/hwixley/WYX-CLI/actions/workflows/main.yml)<br>![License](https://img.shields.io/badge/License-MIT-purple?labelColor=gray&style=flat) ![Version](https://img.shields.io/badge/Version-@VERSION@-blue?labelColor=gray&style=flat) ![Shell Support](https://img.shields.io/badge/Shell%20Support-BASH%20&%20ZSH-orange?labelColor=gray&style=flat) ![Operating Systems](https://img.shields.io/badge/OS%20Support-Debian%20Distros%20&%20MacOS-mediumpurple?labelColor=gray&style=flat)![Git Support](https://img.shields.io/badge/Git%20Support-GitHub,%20GitLab,%20BitBucket,%20&%20Azure%20DevOps-brown?labelColor=gray&style=flat)

<hr>
<p align="center">
<img src="../.generated/wyxcli-output-preview.png" style="width: 90%; display: flex; margin: auto">
</p>

<hr>

## Table of Contents

- [⚡️ WYX CLI ⚡️](#️-wyx-cli-️)
  - [Table of Contents](#table-of-contents)
  - [What It Does](#what-it-does)
  - [Why It Was Made](#why-it-was-made)
  - [Support This Project](#support-this-project)
  - [Installation](#installation)
  - [Extra Feature Setup](#extra-feature-setup)
  - [Factory-reset Installation](#factory-reset-installation)
  - [Dependencies](#dependencies)
  - [List of Commands](#list-of-commands)

<hr>

## What It Does

Provides developers with the ability for optimising the execution of commonly performed tasks, commands, directory navigations, and environment setups/script executions.

## Why It Was Made

I found myself executing the same commands repeatedly, finding navigation on the terminal for frequently accessed locations needlessly slow, and the task of pushing out new code via manually submitting a PR on my browser repetitive and time-wasting. I decided to start developing my own bash scripting library to help alleviate these issues, and realized the whole world of opportunity I had to help optimize my own daily workflows on the terminal. Due to my experience working simultaneously on Mac and Linux machines one of the key parts of the WYX-CLI project was to also allow the same code to run in different shells and operating systems. 

<hr>

## Support This Project

If you have found this tool useful/insightful please leave a :star: on the repository it really helps me out!

I also have a [buymeacoffee](https://www.buymeacoffee.com/hwixley) sponsor link if you would like to help turn my caffeine addiction into a problem :coffee::zap:

<hr>

## Installation

1. Clone this repository into a folder of your choice:

```
git clone git@github.com:hwixley/WYX-CLI.git
```

2. Navigate into the directory:

```
cd WYX-CLI
```

3. Give permissions to the setup script and run it:

```
chmod +x setup.sh && ./setup.sh
```

4. Reopen your terminal or run `source ~/.bashrc` (`source ~/.zshrc` for unix systems)

Type `wyx` to see the list of commands and start developing some magic!

## Extra Feature Setup

1. You can use OpenAI's ChatGPT to write commit messages for you (using `git diff` and `git status` outputs) when using the `wyx push` command. <i>This requires an OpenAI API key.</i>

```
wyx setup smart_commit
```

## Factory-reset Installation

1. Remove your cloned repository

```
rm -rf <path-of-installation>
```

2. Remove the wyx-cli script setup in your environment file
   - Open the file in an editor: (`~/.bashrc` for linux systems, and `~/.zshrc` for unix systems)
     ```
     gedit ~/.bashrc
     ```
     If `gedit` is not available you can always use vim instead:
     ```
     vi ~/.bashrc
     ```
   - Remove the 2 lines for the wyx-cli:<br>
     - The first line is a comment: `# WYX-CLI`<br>
     - The second line is where the command is actually setup: `alias wyx="<path-of-installation>/wyx-cli.sh"`
2. Follow the [installation instructions](https://github.com/hwixley/wyx-cli#installation)

<hr>

## Dependencies
View current dependencies for your system by running:
```
wyx list-deps
```

<hr>

## List of Commands

