# rules\_shtk: Examples of usage with Bazel

This directory contains examples on how to use [rules\_shtk](..) with Bazel.

Each subdirectory contained here provides one specific example scenario
represented as a full-blown Bazel repository.

The examples are the following in order of "complexity":

*   [`binary`](binary): Simple usage of `shtk_binary`.

*   [`test`](test): Simple usage of `shtk_test` to perform end-to-end testing
    of a binary written in C.

*   [`system_toolchain`](system_toolchain): Requests the use of a
    system-installed shtk toolchain so that the built scripts can be taken out
    of the `bazel-bin` directory.
