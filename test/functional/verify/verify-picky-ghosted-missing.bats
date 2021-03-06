#!/usr/bin/env bats

load "../testlib"

test_setup() {

	create_test_environment -r "$TEST_NAME"
	create_bundle -L -n test-bundle -f /usr/foo -d/usr/share/clear/bundles "$TEST_NAME"
	update_manifest "$WEBDIR"/10/Manifest.test-bundle file-status /usr/foo .g..
	# since the files must have been installed by the -L option, remove /usr/foo
	sudo rm -f "$TARGETDIR"/usr/foo

}

@test "VER026: Verify ghosted files are not added during --picky" {

	run sudo sh -c "$SWUPD verify --fix --picky $SWUPD_OPTS"
	assert_status_is 0
	expected_output=$(cat <<-EOM
		Verifying version 10
		Verifying files
		Adding any missing files
		Fixing modified files
		--picky removing extra files under .*/target-dir/usr
		REMOVING /usr/share/defaults/swupd/versionurl
		REMOVING /usr/share/defaults/swupd/contenturl
		Inspected 15 files
		  2 files found which should be deleted
		    2 of 2 files were deleted
		    0 of 2 files were not deleted
		Calling post-update helper scripts.
		Fix successful
	EOM
	)
	assert_regex_is_output "$expected_output"
	# this should not exist at the end, despite being marked in the Manifest as
	# "ghosted". In this case ghosted files should be ignored.
	assert_file_not_exists "$TARGETDIR"/usr/foo

}
