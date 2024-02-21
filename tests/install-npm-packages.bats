#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true
	touch package-lock.json
	mkdir node_modules
}

teardown() {
	rm package-lock.json || true
	rm -r node_modules || true
}

install_npm_packages=$PWD/bin/install-npm-packages

@test "install-npm-packages runs to completion" {
	stub npm ""

	run $install_npm_packages

	assert_line "Installing npm packages."
	assert_file_exist node_modules/cached
	assert_success

	unstub npm
}

@test "install-npm-packages fails if package lock is not found" {
	rm package-lock.json

	run $install_npm_packages

	assert_failure
	assert_line "package-lock.json not found."
}

@test "install-npm-packages skips npm install if marker file exists" {
	touch node_modules/cached

	run $install_npm_packages

	assert_success
	assert_line "node_modules restored from cache. Skipping package install."

}
