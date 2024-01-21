#!/bin/bash

clipboard "$(git rev-parse HEAD)"
git show HEAD