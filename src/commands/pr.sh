#!/bin/bash

sys.log.info "Creating PR for $branch in $repo_url..."
wgit.pr "$branch"