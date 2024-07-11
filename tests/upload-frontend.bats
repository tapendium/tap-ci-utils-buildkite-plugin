#!/usr/bin/env bats

setup() {
	load "$BATS_PLUGIN_PATH/load.bash"

	# Uncomment to enable stub debugging
	export AWS_STUB_DEBUG=/dev/tty

	# Uncomment to enable plugin debugging
	export BUILDKITE_PLUGIN_TAP_CI_UTILS_DEBUG=true
}

upload_frontend=$PWD/bin/upload-frontend

function aws() {
	echo "stubbed aws"
}

@test "upload-frontend runs successfully" {
	export -f aws
	stub hash-dir 'dist : echo directoryhash'
	export TAP_CI_ARGS_UPLOAD_FRONTEND_PACKAGE_PATH="dist"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_BUCKET_NAME="bucketName"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_SERVICE_NAME="service"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_EVENT_BUS="eventBus"
	export TAP_CI_ARGS_UPLOAD_FRONTEND_DETAIL_TYPE="build-completed"

	run $upload_frontend
	assert_success
	assert_output -p "Uploading package to S3"
	refute_output -p "DRY RUN"
	unstub hash-dir
}

@test "upload-frontend runs handles dry run" {
	export -f aws
	stub hash-dir 'dist : echo directoryhash'
	export TAP_CI_ARGS_UPLOAD_FRONTEND_PACKAGE_PATH="dist"
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
	unstub hash-dir
}
