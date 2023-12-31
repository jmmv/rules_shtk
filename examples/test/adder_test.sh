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

shtk_import unittest


shtk_unittest_add_test addition_works
addition_works_test() {
    expect_command \
        -o inline:"The sum of 2 and 3 is 5\n" \
        ../adder 2 3

    expect_command \
        -o inline:"The sum of -12345 and 12345 is 0\n" \
        ../adder -12345 12345
}


shtk_unittest_add_test bad_first_operand
bad_first_operand_test() {
    expect_command \
        -s 1 \
        -e inline:"adder: Invalid first operand: out of range\n" \
        ../adder 123456789 0

    expect_command \
        -s 1 \
        -e inline:"adder: Invalid first operand: bad digits\n" \
        ../adder "" 0

    expect_command \
        -s 1 \
        -e inline:"adder: Invalid first operand: bad digits\n" \
        ../adder 123x 0

    expect_command \
        -s 1 \
        -e inline:"adder: Invalid first operand: out of range\n" \
        ../adder -123456789 0
}


shtk_unittest_add_test bad_second_operand
bad_second_operand_test() {
    expect_command \
        -s 1 \
        -e inline:"adder: Invalid second operand: out of range\n" \
        ../adder 0 123456789

    expect_command \
        -s 1 \
        -e inline:"adder: Invalid second operand: bad digits\n" \
        ../adder 0 ""

    expect_command \
        -s 1 \
        -e inline:"adder: Invalid second operand: bad digits\n" \
        ../adder 0 123x

    expect_command \
        -s 1 \
        -e inline:"adder: Invalid second operand: out of range\n" \
        ../adder 0 -123456789
}


shtk_unittest_add_test bad_arguments
bad_arguments_test() {
    expect_command \
        -s 1 -e inline:"adder: Requires two integer arguments\n" ../adder
    expect_command \
        -s 1 -e inline:"adder: Requires two integer arguments\n" ../adder 1
    expect_command \
        -s 1 -e inline:"adder: Requires two integer arguments\n" ../adder 1 2 3
}
