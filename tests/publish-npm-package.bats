#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true
	# export NPM_STUB_DEBUG=/dev/tty
	# export JQ_STUB_DEBUG=/dev/tty
	touch package.json
}

teardown() {
	rm package.json || true
}

publish_npm_package=$PWD/bin/publish-npm-package

@test "publish-npm-package fails if package.json is not found" {
	rm package.json

	run $publish_npm_package

	assert_failure
	assert_line --partial "No package.json file found"
}

@test "publish-npm-package runs to completion" {
	stub jq "--raw-output .name package.json : echo test-package"
	stub npm "view test-package dist.shasum : echo remote-shasum"
	stub npm "publish --dry-run --json : echo local-shasum"
	stub npm "view test-package version : echo remote-version"
	stub jq "--raw-output '.. | objects | .shasum // empty' : echo local-shasum"
	stub npm "version patch : echo npm-version"
	stub npm "publish : echo package-published"

	run $publish_npm_package
	assert_success

	unstub jq
	unstub npm
}

@test "publish-npm-package uses environment variables for configuration" {
	export TAP_CI_ARGS_PUBLISH_NPM_PACKAGE_DRY_RUN=true
	export TAP_CI_ARGS_PUBLISH_NPM_PACKAGE_USE_REMOTE=true
	export TAP_CI_ARGS_PUBLISH_NPM_PACKAGE_NEW_VERSION=minor

	stub jq "--raw-output .name package.json : echo test-package"
	stub npm "view test-package dist.shasum : echo remote-shasum"
	stub npm "publish --dry-run --json : echo local-shasum"
	stub jq "--raw-output '.. | objects | .shasum // empty' : echo local-shasum"
	stub npm "view test-package version : echo remote-version"
	stub npm "version remote-version : echo remote-version"
	stub npm "version minor : echo npm-version"
	stub npm "publish --dry-run : echo dry-run-published"

	run $publish_npm_package

	assert_success
	unstub jq
	unstub npm
}

@test "publish-npm-package command line arguments override environment variables" {
	export TAP_CI_ARGS_PUBLISH_NPM_PACKAGE_DRY_RUN=false
	export TAP_CI_ARGS_PUBLISH_NPM_PACKAGE_USE_REMOTE=false
	export TAP_CI_ARGS_PUBLISH_NPM_PACKAGE_NEW_VERSION=patch

	stub jq "--raw-output .name package.json : echo test-package"
	stub npm "view test-package dist.shasum : echo remote-shasum"
	stub npm "publish --dry-run --json : echo local-shasum"
	stub jq "--raw-output '.. | objects | .shasum // empty' : echo local-shasum"
	stub npm "view test-package version : echo remote-version"
	stub npm "version major : echo npm-version"
	stub npm "publish --dry-run : echo dry-run-published"

	run $publish_npm_package -n major

	assert_success
	unstub jq
	unstub npm
}

@test "publish-npm-package uses default values when environment variables are not set" {
	stub jq "--raw-output .name package.json : echo test-package"
	stub npm "view test-package dist.shasum : echo remote-shasum"
	stub npm "publish --dry-run --json : echo local-shasum"
	stub jq "--raw-output '.. | objects | .shasum // empty' : echo local-shasum"
	stub npm "view test-package version : echo remote-version"
	stub npm "version patch : echo npm-version"
	stub npm "publish : echo package-published"

	run $publish_npm_package

	assert_success
	unstub jq
	unstub npm
}

# TODO Fix flaky tests
# https://benieworldwide.atlassian.net/browse/LIBS-365

# @test "publish-npm-package handles unpublished packages" {
# 	stub jq "--raw-output .name package.json : echo test-package"
# 	stub npm "view test-package dist.shasum : exit 1"
# 	stub npm "publish --dry-run --json : echo local-shasum"
# 	stub npm "view test-package version : exit 1"
# 	stub jq "--raw-output '.shasum' : echo local-shasum"
# 	stub npm "version patch : echo npm-version"
# 	stub npm "publish : echo package-published"

# 	run $publish_npm_package
# 	assert_success

# 	unstub jq
# 	unstub npm
# }

# @test "publish-npm-package supports an optional -n dry-run option" {
# 	stub jq "--raw-output .name package.json : echo test-package"
# 	stub npm "view test-package dist.shasum : echo remote-shasum"
# 	stub npm "publish --dry-run --json : echo local-shasum"
# 	stub npm "view test-package version : echo remote-version"
# 	stub jq "--raw-output '.shasum' : echo local-shasum"
# 	stub npm "version patch : echo npm-version"
# 	stub npm "publish --dry-run : echo dry-run"

# 	run $publish_npm_package -n
# 	assert_success
# 	assert_line dry-run

# 	unstub jq
# 	unstub npm
# }

# @test "publish-npm-package fails for invalid options" {
# 	run $publish_npm_package -x
# 	assert_failure
# 	assert_line "Invalid option: -x"
# }

# @test "publish-npm-package supports an optional -r use-remote option" {
# 	stub jq "--raw-output .name package.json : echo test-package"
# 	stub npm "view test-package dist.shasum : echo remote-shasum"
# 	stub npm "publish --dry-run --json : echo local-shasum"
# 	stub npm "view test-package version : echo remote-version"
# 	stub jq "--raw-output '.shasum' : echo local-shasum"
# 	stub npm "version remote-version : echo remote-version"
# 	stub npm "version patch : echo npm-version"
# 	stub npm "publish : echo package-published"

# 	run $publish_npm_package -r
# 	assert_success

# 	unstub jq
# 	unstub npm
# }

# @test "-r options handles unpublished packages" {
# 	stub jq "--raw-output .name package.json : echo test-package"
# 	stub npm "view test-package dist.shasum : exit 1"
# 	stub npm "publish --dry-run --json : echo local-shasum"
# 	stub npm "view test-package version : exit 1"
# 	stub jq "--raw-output '.shasum' : echo local-shasum"
# 	stub npm "version patch : echo npm-version"
# 	stub npm "publish : echo package-published"

# 	run $publish_npm_package -r
# 	assert_success

# 	unstub jq
# 	unstub npm

# }
