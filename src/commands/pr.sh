#!/bin/bash

sys.info "Creating PR for $branch in $repo_url..."
giturl "https://github.com/$repo_url/pull/new/$branch"