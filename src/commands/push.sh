#!/bin/bash

if wyxd.arggt "1" ; then
    wgit.push "$1"
else
    wgit.push "$branch"
fi