#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable plugin debugging
	#export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true
}

teardown() {
	rm features.json
}

validate_features=$PWD/bin/validate-features

@test "validate-features detects a single invalid feature" {
	cat <<-EOF >features.json
		[
		  "service.action.off.V1",
		  "service.entity.read.V1",
		  "service.action.on.missingversion",
		  "service.entity.update.V1"
		]
	EOF
	run $validate_features
	assert_failure
	assert_line "Feature service.action.on.missingversion does not match expected format."
	assert_line "One or more features do not match expected format."
}

@test "validate-features succeeds for valid features" {
	cat <<-EOF >features.json
		[
		  "service-a.action.off.V1",
		  "service_b.entity.read.V1",
		  "service.entity.update.V1"
		]
	EOF
	run $validate_features
	assert_success
}
