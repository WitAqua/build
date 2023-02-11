#!/bin/bash
# Script to perform a 1st step of Android Finalization: API/SDK finalization, create CLs and upload to Gerrit.

set -ex

function commit_step_1_changes() {
    set +e
    repo forall -c '\
        if [[ $(git status --short) ]]; then
            repo start "$FINA_PLATFORM_CODENAME-SDK-Finalization" ;
            git add -A . ;
            git commit -m "$FINA_PLATFORM_CODENAME is now $FINA_PLATFORM_SDK_VERSION" \
                       -m "Ignore-AOSP-First: $FINA_PLATFORM_CODENAME Finalization
Bug: $FINA_BUG_ID
Test: build";
            repo upload --cbr --no-verify -o nokeycheck -t -y . ;
            git clean -fdx ; git reset --hard ;
        fi'
}

function finalize_step_1_main() {
    local top="$(dirname "$0")"/../../../..
    source $top/build/make/tools/finalization/environment.sh

    local m="$top/build/soong/soong_ui.bash --make-mode TARGET_PRODUCT=aosp_arm64 TARGET_BUILD_VARIANT=userdebug"

    # vndk etc finalization
    source $top/build/make/tools/finalization/finalize-aidl-vndk-sdk-resources.sh

    # build to confirm everything is OK
    AIDL_FROZEN_REL=true $m

    # move all changes to finalization branch/topic and upload to gerrit
    commit_step_1_changes
}

finalize_step_1_main