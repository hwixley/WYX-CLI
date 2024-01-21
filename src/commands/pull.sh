#!/bin/bash

if wixd.arggt "1" ; then
    wgit.pull "$1"
else
    wgit.pull "$branch"
fi