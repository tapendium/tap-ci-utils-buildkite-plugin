#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	export AWS_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true

	test_dir="$(temp_make)"
	mkdir -p "$test_dir/dist"
	touch "$test_dir/dist/tapendium-service.js"
	export PATH="$PWD/bin:$PATH"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_PACKAGE_DIR="$test_dir/dist"
}

upload_frontend=$PWD/bin/upload-frontend

teardown() {
	temp_del "$test_dir"
}

function aws() {
	if [[ "$1" == "cloudformation" && "$2" == "list-exports" ]]; then
		echo "example.com"
	else
		echo "stubbed aws"
	fi
}

@test "upload-frontend runs successfully" {
	export -f aws
	stub curl '-sI * : echo "content-type: application/javascript"'
	export TAP_CI_ARGS_UPLOAD_FRONTEND_BUCKET_NAME="bucketName"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_SERVICE_NAME="service"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_EVENT_BUS="eventBus"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_DETAIL_TYPE="build-completed"

	run $upload_frontend
	assert_success
	assert_output -p "Uploading package to S3"
	assert_output -p "Fetching CloudFront domain"
	assert_output -p "Validating uploaded resource URL"
	refute_output -p "DRY RUN"
	unstub curl
}

@test "upload-frontend runs handles dry run" {
	export -f aws
	export TAP_CI_ARGS_UPLOAD_FRONTEND_BUCKET_NAME="bucketName"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_SERVICE_NAME="service"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_EVENT_BUS="eventBus"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_DRY_RUN="true"
	export BUILD_TYPE="build-completed"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_DETAIL_TYPE="\$BUILD_TYPE"

	run $upload_frontend
	assert_success
	assert_output -p "[DRY RUN] Uploading package to S3"
	assert_output -p "[DRY RUN] Putting event"
}

@test "upload-frontend fails when file_name does not exist" {
	export -f aws
	export TAP_CI_ARGS_UPLOAD_FRONTEND_BUCKET_NAME="bucketName"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_SERVICE_NAME="service"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_EVENT_BUS="eventBus"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_DETAIL_TYPE="build-completed"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_FILE_NAME="nonexistent.js"

	run $upload_frontend
	assert_failure
	assert_output -p "does not exist in"
}
