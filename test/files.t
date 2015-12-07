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

hg_add_file() {
	echo test > one &&
	hg add one &&
	hg commit -m add_file
}

hg_add_symlink() {
	ln -s fake one &&
	hg add one &&
	hg commit -m add_link
}

hg_add_dir() {
	mkdir one &&
	echo test > one/two &&
	hg add one/two &&
	hg commit -m add_dir
}


test_expect_success 'cloning a removed file' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	hg_add_file &&

	hg rm one &&
	hg commit -m remove
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo
'

test_expect_success 'file replaced by directory' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	hg_add_file &&
	hg rm one &&
	hg_add_dir
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo "one/two"
'

test_expect_success 'file replaced by symlink' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	hg_add_file &&
	hg rm one &&
	hg_add_symlink
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo "one"
'

test_expect_success 'directory replaced by file' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	hg_add_dir &&
	hg rm one/two &&
	hg_add_file
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo "one"
'

test_expect_success 'directory replaced by symlink' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	hg_add_dir &&
	hg rm one/two &&
	hg_add_symlink
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo "one"
'

test_expect_success 'symlink replaced by directory' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	hg_add_symlink &&
	hg rm one &&
	hg_add_dir
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo "one/two"
'

test_expect_success 'symlink replaced by file' '
	test_when_finished "rm -rf hgrepo gitrepo" &&

	(
	hg init hgrepo &&
	cd hgrepo &&

	hg_add_symlink &&
	hg rm one &&
	hg_add_file
	) &&

	git clone "hg::hgrepo" gitrepo &&
	check_files gitrepo "one"
'

test_done
