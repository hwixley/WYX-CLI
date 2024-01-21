#!/bin/bash

if wixd.arggt "1" ; then
    wgit.push "$1"
else
    wgit.push "$branch"
fi