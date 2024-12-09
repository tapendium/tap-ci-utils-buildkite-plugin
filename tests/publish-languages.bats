#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	# export AWS_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true

	cat <<-EOF >en.json
		    {
		      "login.form.login": "Login",
		      "login.form.email": "Email",
		      "login.form.login.successful": "Login Successful",
		      "login.form.invalid.email": "Invalid Email",
		      "login.form.register": "Register",
		      "register.form.register": "Register",
		      "register.form.first.name": "First Name",
		      "register.form.last.name": "Last Name",
		      "register.form.email": "Email"
		    }
	EOF
}

teardown() {
	rm en.json
}

publish_languages=$PWD/bin/publish-languages

@test "publish-languages runs successfully" {
	stub aws "$(cat ./tests/fixtures/put-events-input-args-languages.stub) : cat ./tests/fixtures/put-events-success.json"
	export BUILDKITE_REPO="git@github.com:org/service-name.git"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_DEBUG=true
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_FILE_PATH="en.json"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_SERVICE_NAME="service-name"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_EVENT_BUS="eventbusnameorarn"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_DETAIL_TYPE="languages.updated"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_USER_ID="abc123"
	run $publish_languages

	assert_success
	assert_line "Published languages for service: service-name"

	unstub aws
}

@test "publish-languages handles eventbridge failures" {
	stub aws "$(cat ./tests/fixtures/put-events-input-args-languages.stub) : cat ./tests/fixtures/put-events-failure.json"
	export BUILDKITE_REPO="git@github.com:org/service-name.git"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_DEBUG=true
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_FILE_PATH="en.json"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_SERVICE_NAME="service-name"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_EVENT_BUS="eventbusnameorarn"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_DETAIL_TYPE="languages.updated"
	export TAP_CI_ARGS_PUBLISH_LANGUAGES_USER_ID="abc123"
	run $publish_languages

	assert_failure
	assert_line "Failed to publish languages to EventBridge"

	unstub aws

}
