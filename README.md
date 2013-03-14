Ukigumo-Agent
=============

Test runner server for [Ukigumo CI tool set](http://ukigumo.github.com/ukigumo/).

![Screen shot](http://gyazo.64p.org/image/8896fde65e8d9e8020fb6eb3e2bc888e.png)

This server runs test cases by git hooks.

## Installation

### Install from Git

First, install carton to your system

    % curl -L http://cpanmin.us | perl - Carton

And setup the depended modules.

    % carton install

Then, run the http server!

    % carton exec -- perl bin/ukigumo-agent --work_dir=$HOME/.ukigumo/ --server_url=http://127.0.0.1:5000

### Install from CPAN

TBD

## Git hooks

You can add hook script for your remote git repo.

Put following code to `hooks/post-receive`, and `chmod +x`.

    #!/bin/sh
    
    while read oldrev newrev refname
    do
        branch=$(git rev-parse --symbolic --abbrev-ref $refname)
        repo_url=git://example.com/example.git
        ukigumo_base="http://127.0.0.1:1984"

        curl --fail --silent -X POST "$ukigumo_base/api/v0/enqueue?repository=$repo_url&branch=$branch&oldrev=$oldrev&newrev=$newrev"
    done

Then, git repo calls ukigumo-agent server after push, automatically.

