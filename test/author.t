#!/bin/sh

test_description='Test author name conversion'
. ./test-lib.sh


# author_test 
author_test () {
	echo $1 >> content &&
	hg commit -u "$2" -m "add $1" &&
	echo "$3" >> ../expected
}

test_expect_success 'authors' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	touch content &&
	hg add content &&

	> ../expected &&
	# valid input
	author_test alpha "" "H G Wells <wells@example.com>" &&
	author_test beta "beta <email@example.com>" "beta <email@example.com>" &&

	# missing email
	author_test gamma "gamma" "gamma <unknown>" &&

	# missing name
	author_test delta "<delta@example.com>" "Unknown <delta@example.com>" &&

	# comment after email
	author_test epsilon "epsilon <email@example.com> (comment)" "epsilon <email@example.com>" &&

	# missing name, missing email quotes
	author_test zeta "zeta@example.com" "Unknown <zeta@example.com>" &&
	author_test eta "eta.eta@example.com" "Unknown <eta.eta@example.com>" &&

	# missing space between name and email
	author_test theta "theta<email@example.com>" "theta <email@example.com>" &&

	# email missing end quote
	author_test iota "iota <email@example.com" "iota <email@example.com>" &&

	# extra spaces
	author_test kappa " kappa " "kappa <unknown>" &&
	author_test lambda "lambda < email@example.com >" "lambda <email@example.com>" &&
	
	# invalid but acceptable email (e.g. obfuscated)
	author_test mu "mu <email (at) example dot com>" "mu <email (at) example dot com>" &&

	# bad use of email quotes
	author_test nu "nu >email@example.com>" "nu <email@example.com>" &&
	author_test xi "xi < email <at> example <dot> com>" "xi <unknown>"
	) &&

	git clone "hg::hgrepo" gitrepo &&
	git --git-dir=gitrepo/.git log --reverse --format="%an <%ae>" > actual &&

	test_cmp expected actual
'

test_done
