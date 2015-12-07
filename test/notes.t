#!/bin/sh

test_description='Test notes'
. ./test-lib.sh

test_expect_success 'notes' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&
	echo one > content &&
	hg add content &&
	hg commit -m one &&
	echo two > content &&
	hg commit -m two
	) &&

	git clone "hg::hgrepo" gitrepo &&
	hg -R hgrepo log --template "{node}\n\n" > expected &&
	git --git-dir=gitrepo/.git log --pretty="tformat:%N" --notes=hg > actual &&
	test_cmp expected actual
'

test_expect_failure 'push updates notes' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&
	echo one > content &&
	hg add content &&
	hg commit -m one
	) &&

	git clone "hg::hgrepo" gitrepo &&

	(
	cd gitrepo &&
	echo two > content &&
	git commit -a -m two
	git push
	) &&

	hg -R hgrepo log --template "{node}\n\n" > expected &&
	git --git-dir=gitrepo/.git log --pretty="tformat:%N" --notes=hg > actual &&
	test_cmp expected actual
'

test_done
