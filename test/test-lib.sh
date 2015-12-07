#!/bin/sh

. ./sharness.sh

if ! command -v python2 >/dev/null
then
	skip_all='skipping remote-hg tests; python not available'
	test_done
fi

if ! python2 -c 'import mercurial' > /dev/null 2>&1
then
	skip_all='skipping remote-hg tests; mercurial not available'
	test_done
fi

if ! command -v git >/dev/null
then
	skip_all='skipping remote-hg tests; git not available'
	test_done
fi

GIT_VERSION=$(git --version)
GIT_MAJOR=$(expr "$GIT_VERSION" : '[^0-9]*\([0-9]*\)')
GIT_MINOR=$(expr "$GIT_VERSION" : '[^0-9]*[0-9]*\.\([0-9]*\)')
test "$GIT_MAJOR" -ge 2 && test_set_prereq GIT_2_0


# setup git to use uniform commit author and committer
# names and dates
export GIT_AUTHOR_EMAIL=author@example.com
export GIT_AUTHOR_NAME='A U Thor'
export GIT_COMMITTER_EMAIL=committer@example.com
export GIT_COMMITTER_NAME='C O Mitter'

export GIT_AUTHOR_DATE="2007-01-01 00:00:00 +0230"
export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"


# setup to use ise uniform commit dates and username
cat > "$HOME"/.hgrc <<-EOF
[ui]
username = H G Wells <wells@example.com>
[defaults]
backout = -d "0 0"
commit = -d "0 0"
debugrawcommit = -d "0 0"
tag = -d "0 0"
[extensions]"
graphlog =
EOF

# silence warnings about push default
git config --global push.default simple


export HGEDITOR=true
export HGMERGE=true
