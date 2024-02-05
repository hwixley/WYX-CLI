#!/bin/bash

if [ "$(git branch --list master)" ]; then
    wgit.pull "master"
elif [ "$(git branch --list main)" ]; then
    wgit.pull "main"
else
 sys.log.warn "No master or main branch found..."
fi