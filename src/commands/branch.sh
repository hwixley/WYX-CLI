#!/bin/bash

sys.log.info "Redirecting to $branch on $repo_url..."
wgit.giturl "https://github.com/$repo_url/tree/$branch"