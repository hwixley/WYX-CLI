#!/bin/bash

sys.log.info "Redirecting to Pull Requests on $repo_url..."
wgit.giturl "https://github.com/$repo_url/pulls"