#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/src/classes/command/command.h
source $(dirname ${BASH_SOURCE[0]})/src/classes/system/system.h
# source $(dirname ${BASH_SOURCE[0]})/src/classes/system/lib.h

command newCommand

newCommand.sayHello

newCommand.id = "genpass"

newCommand.path

# new.fileName = "file1"

# system.stdout.printString "value is"
# system.stdout.printValue myobject.fileName