#!/bin/sh

test_description='Test various file operations'
. ./test-lib.sh

check_files () {
	git --git-dir=$1/.git ls-files > actual &&
	if test $# -gt 1
	then
		printf "%s\n" "$2" > expected
	else
		> expected
	fi &&
	test_cmp expected actual
}


test_expect_success 'cloning a removed file works' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	echo test > test_file &&
	hg add test_file &&
	hg commit -m add &&

	hg rm test_file &&
	hg commit -m remove
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo
'

test_expect_success 'cloning a file replaced with a directory' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	echo test > dir_or_file &&
	hg add dir_or_file &&
	hg commit -m add &&

	hg rm dir_or_file &&
	mkdir dir_or_file &&
	echo test > dir_or_file/test_file &&
	hg add dir_or_file/test_file &&
	hg commit -m replase
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo "dir_or_file/test_file"
'

test_expect_success 'clone replace directory with a file' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	mkdir dir_or_file &&
	echo test > dir_or_file/test_file &&
	hg add dir_or_file/test_file &&
	hg commit -m add &&

	hg rm dir_or_file/test_file &&
	echo test > dir_or_file &&
	hg add dir_or_file &&
	hg commit -m add &&

	hg rm dir_or_file
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo "dir_or_file"
'

test_done
