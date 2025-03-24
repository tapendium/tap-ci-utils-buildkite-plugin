#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	# export AWS_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true
}

put_param=$PWD/bin/put-param

@test "put_param shows an error message when param name is not provided" {
	run $put_param

	assert_failure
	assert_output --partial "Parameter name is not set"
}

@test "put_param shows an error message when param value is not provided" {
	run $put_param "/test/param"

	assert_failure
	assert_output --partial "Parameter value is not set"
}

@test "param_exists produces correct output to aws ssm" {
	stub aws "ssm put-parameter --name test-param --value test-value --type String --overwrite : echo success"

	run $put_param test-param test-value
	assert_success
	assert_output success
}
