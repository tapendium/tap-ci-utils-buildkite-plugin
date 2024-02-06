#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	# export AWS_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true

	cat <<-EOF >features.json
		[
		  "service.action.on.V1",
		  "service.action.off.V1",
		  "service.entity.read.V1",
		  "service.entity.update.V1"
		]
	EOF
}

teardown() {
	rm features.json
}

publish_features=$PWD/bin/publish-features

@test "publish-features runs to completion" {
	stub aws "$(cat ./tests/fixtures/put-events-input-args.stub) : cat ./tests/fixtures/put-events-success.json"
	export BUILDKITE_REPO="git@github.com:org/service-name.git"
	export PUBLISH_FEATURES_EVENT_BUS_NAME="eventbusnameorarn"
	export PUBLISH_FEATURES_EVENT_USER_ID="abc123"
	export PUBLISH_FEATURES_DETAIL_TYPE="features.updated"
	run $publish_features

	assert_success
	assert_line "Published features for service: service-name"

	unstub aws
}

@test "publish-features handles eventbridge failures" {
	stub aws "$(cat ./tests/fixtures/put-events-input-args.stub) : cat ./tests/fixtures/put-events-failure.json"
	export BUILDKITE_REPO="git@github.com:org/service-name.git"
	export PUBLISH_FEATURES_EVENT_BUS_NAME="eventbusnameorarn"
	export PUBLISH_FEATURES_EVENT_USER_ID="abc123"
	export PUBLISH_FEATURES_DETAIL_TYPE="features.updated"
	run $publish_features

	assert_failure
	assert_line "Failed to publish features to EventBridge"

	unstub aws

}
