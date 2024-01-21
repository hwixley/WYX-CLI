#!/bin/bash

if arggt "1" ; then
    push "$1"
else
    push "$branch"
fi