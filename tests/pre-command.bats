#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	# export MISE_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	# export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true

}

pre_command=$PWD/hooks/pre-command

@test "pre-command runs successfully" {
	test_dir="$(temp_make)"
	export TAP_CI_ARGS_SETUP_WORKING_DIR="$test_dir"
	stub mise "install : echo mise-install"

	run $pre_command
	assert_success
	assert_line "--- Changing working directory to $test_dir"

	unstub mise
	temp_del "$test_dir"
}

@test "pre-command leaves current dir unchanged when working_dir not set" {
	stub mise "install : echo mise-install"

	run $pre_command
	assert_success
	refute_line --partial "--- Changing working directory"

	unstub mise
}

@test "pre-command does not install tools if install_tools is set to false" {
	test_dir="$(temp_make)"
	export TAP_CI_ARGS_SETUP_WORKING_DIR="$test_dir"
	export TAP_CI_ARGS_SETUP_INSTALL_TOOLS=false

	run $pre_command
	assert_success
	refute_line "Installing required tools"
	temp_del "$test_dir"
}
