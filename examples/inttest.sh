# Copyright 2023 Julio Merino
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# * Neither the name of rules_shtk nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

shtk_import cli
shtk_import unittest


one_time_setup() {
    # REAL_HOME provides access to the Bazel and Bazelisk caches from within this
    # test program.  While not strictly necessary, this makes these tests much
    # faster than they would otherwise and minimizes network traffic.
    [ "${REAL_HOME-unset}" != unset ] \
        || shtk_cli_error "REAL_HOME must point to the user's home directory"

    # WORKSPACE points to the root of the bazel_examples directory so that we can
    # run Bazel on it.
    [ "${WORKSPACE-unset}" != unset ] \
        || shtk_cli_error "WORKSPACE must point to the bazel_examples directory"

    # Create a fake Bazel binary that is aware of our configuration variables
    # above.  We do this so that we can invoke this wrapper via assert_command.
    #
    # The first argument to the wrapper is the name of the subdirectory of the
    # workspace (aka the name of the example) to run Bazel under.  These names
    # are saved in a "dirs.txt" file to be able to shut down all Bazel instances
    # when the tests are done.
    touch dirs.txt
    local real_bazel="$(which bazel)"
    cat >run_bazel <<EOF
#! /bin/sh

example="\${1}"; shift
echo "\${example}" >>"$(pwd)/dirs.txt"

cd "${WORKSPACE}/\${example}"

export HOME="${REAL_HOME}"
exec "${real_bazel}" "\${@}"
EOF
    chmod +x run_bazel
}


one_time_teardown() {
    for dir in $(sort dirs.txt | uniq); do
        ./run_bazel "${dir}" shutdown
    done
}


do_binary_test() {
    local style="${1}"; shift

    assert_command -o ignore -e ignore ../run_bazel "${style}/binary" build //:simple
    assert_command -e match:"Hello, world" "${WORKSPACE}/${style}/binary/bazel-bin/simple"
}


shtk_unittest_add_test workspace_binary
workspace_binary_test() {
    do_binary_test workspace
}


do_test_test() {
    local style="${1}"; shift

    # Sanity-check that the binary tool we want to test works.
    assert_command -o ignore -e ignore ../run_bazel "${style}/test" build //:adder
    assert_command \
        -o inline:"The sum of 2 and 3 is 5\n" \
        "${WORKSPACE}/${style}/test/bazel-bin/adder" 2 3

    assert_command \
        -o match:"addition_works... PASSED" \
        -o match:"bad_first_operand... PASSED" \
        -o match:"bad_second_operand... PASSED" \
        -e ignore \
        ../run_bazel "${style}/test" test --nocache_test_results --test_output=streamed \
        //:adder_test
}


shtk_unittest_add_test workspace_test
workspace_test_test() {
    do_test_test workspace
}


do_system_toolchain_test() {
    local style="${1}"; shift

    local bin="${WORKSPACE}/${style}/system_toolchain/bazel-bin/simple"
    assert_command -o ignore -e ignore ../run_bazel "${style}/system_toolchain" build //:simple
    assert_command -e match:"Hello, world" "${bin}"
    grep -q SHTK_MODULESDIR.*local "${bin}" \
        || fail "SHTK_MODULESDIR does not point to a local installation"
    ! grep -q SHTK_MODULESDIR.*.cache/bazel "${bin}" \
        || fail "SHTK_MODULESDIR does not point to a local installation"
}


shtk_unittest_add_test workspace_system_toolchain
workspace_system_toolchain_test() {
    do_system_toolchain_test workspace
}


do_system_toolchain_not_present_test() {
    local style="${1}"; shift

    # Compute a new PATH that does not contain shtk.
    local newpath=
    local oldifs="${IFS}"
    IFS=:
    for dir in ${PATH}; do
        if [ ! -e "${dir}/shtk" ]; then
            if [ -z "${newpath}" ]; then
                newpath="${dir}"
            else
                newpath="${newpath}:${dir}"
            fi
        fi
    done
    IFS="${oldifs}"

    # We shouldn't be writing into the workspace, but this is much easier to do...
    # and given that this is only for the testing that happens in GitHub Actions,
    # it just doesn't matter.
    rm -rf "${WORKSPACE}/${style}/system_toolchain_not_present"
    cp -rf "${WORKSPACE}/${style}/system_toolchain" "${WORKSPACE}/${style}/system_toolchain_not_present"

    PATH="${newpath}" assert_command \
        -s 1 \
        -o ignore \
        -e match:"shtk cannot be found in the PATH" \
        ../run_bazel "${style}/system_toolchain_not_present" build //:simple
}


shtk_unittest_add_test workspace_system_toolchain_not_present
workspace_system_toolchain_not_present_test() {
    do_system_toolchain_not_present_test workspace
}
