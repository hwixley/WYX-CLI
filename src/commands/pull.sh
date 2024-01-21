#!/bin/bash

if arggt "1" ; then
    pull "$1"
else
    pull "$branch"
fi