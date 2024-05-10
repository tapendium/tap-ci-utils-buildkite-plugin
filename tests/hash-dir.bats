#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	# export AWS_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true
}

hash_dir=$PWD/bin/hash-dir

@test "hash-dir shows an error message when path is not set" {
	run $hash_dir

	assert_failure
	assert_output --partial "Path is not set"
}

@test "hash-dir shows an error message when path is not a valid directory" {
	run $hash_dir thisdoesnotexist

	assert_failure
	assert_line "thisdoesnotexist is not a valid directory."
}

@test "hash-dir runs to completion" {
	test_dir="$(temp_make)"

	run $hash_dir "$test_dir"
	assert_success

	temp_del "$test_dir"
}

@test "hash-dir produces the correct hash" {
	test_dir="$(temp_make)"
	echo a >"$test_dir/a"
	echo b >"$test_dir/b"

	run $hash_dir "$test_dir"
	assert_success
	assert_output --regexp '^[a-f0-9]{32}$'

	temp_del "$test_dir"
}
