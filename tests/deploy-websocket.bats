#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	# export AWS_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true
}

deploy_websocket=$PWD/bin/deploy-websocket

@test "create-deployment runs to completion" {
	stub aws "$(cat ./tests/fixtures/create-deployment-args.stub) : cat ./tests/fixtures/put-events-success.json"
	export MATRIX="test"
	export API_GATEWAY_WEBSOCKETAPIID="testApi"
	export DESCRIPTION="Hello"
	run $deploy_websocket

	assert_success
	assert_line "Created deployment on API Websocket Gateway"

	unstub aws
}

@test "create-deployment handles failures" {
	stub aws "$(cat ./tests/fixtures/create-deployment-args.stub) : cat ./tests/fixtures/put-events-failure.json"
	export MATRIX="test"
	export API_GATEWAY_WEBSOCKETAPIID="testApi"
	export DESCRIPTION="Hello"
	run $deploy_websocket

	assert_failure
	assert_line "Failed to create deploy on API Websocket Gateway"

	unstub aws
}
