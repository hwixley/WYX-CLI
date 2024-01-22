#!/bin/bash

sys.util.clipboard "$(git rev-parse HEAD)"
git show HEAD