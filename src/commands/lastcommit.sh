#!/bin/bash

sys.clipboard "$(git rev-parse HEAD)"
git show HEAD