#!/bin/bash

if [ "$(git branch --list master)" ]; then
    pull "master"
elif [ "$(git branch --list main)" ]; then
    pull "main"
else
    sys.warn "No master or main branch found..."
fi