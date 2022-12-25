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

### General Utility

### Directory Management

### Code Editing

### Git Automation

### Quick-access URLs

### Customisable Data for Custom Scripting Logic
