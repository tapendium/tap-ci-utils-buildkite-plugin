#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	# export AWS_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true
}

param_exists=$PWD/bin/param-exists

@test "param_exists shows an error message when param name is not provided" {
	run $param_exists

	assert_failure
	assert_output --partial "Parameter name is not set"
}

@test "param_exists returns a 0 exit code for parameter which exists" {
	stub aws "ssm get-parameter --name /existing/param --query Parameter.Name --output text : echo exists"

	run $param_exists "/existing/param"
	assert_success

	unstub aws
}

@test "param_exists returns a non-zero exit code for a parameter which does not exist" {
	stub aws "ssm get-parameter --name /invalid/param --query Parameter.Name --output text : exit 254"

	run $param_exists "/invalid/param"
	assert_failure

	unstub aws
}
