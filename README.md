# rules\_shtk: Bazel rules for shtk

This directory contains Bazel rules to build shtk scripts and run shtk tests
from Bazel.

The major selling point of these rules is to leverage shtk to write and run
end-to-end unit tests for binaries you build with Bazel, especially if those
binaries are CLI tools.  Shell scripts are uniquely suited to drive the
execution of tools, and shtk's `unittest` module provides facilities to define
test cases and fixtures, and to assert the behavior of command invocations.

For more information about shtk, visit <https://shtk.jmmv.dev/>.

## Set up with bzlmod

To get started, add the following entry to your `MODULE.bazel`:

```python
bazel_dep(name = "rules_shtk", version = "1.7.1")
```

Then, load an shtk toolchain from `MODULE.bazel` as well.  You can choose
between:

*   `fetch_shtk_dist`, which downloads the version of shtk corresponding to the
    rules and builds it.  This is typically what you should use, especially if
    all you care about is building and running tests from within Bazel.

    ```python
    # Use the shtk release that matches these rules (if these rules are version
    # 1.7.x, then this uses shtk 1.7).
    fetch_shtk_dist = use_extension("@rules_shtk//:extensions.bzl", "fetch_shtk_dist")
    use_repo(fetch_shtk_dist, "shtk_dist_1_7")
    register_toolchains("@shtk_dist_1_7//:toolchain")
    ```

*   `find_shtk_system`, which discovers an shtk toolchain installed on the
    system.  Use this if you need to install the built scripts.

    ```python
    # Auto-discover the system-provided shtk by looking for shtk(1) in the PATH.
    find_shtk_system = use_extension("@rules_shtk//:extensions.bzl", "find_shtk_system")
    use_repo(find_shtk_system, "shtk_autoconf")
    register_toolchains("@shtk_autoconf//:toolchain")

    # Auto-discover the system-provided shtk by looking for shtk(1) in the PATH
    # and ensure that the discovered toolchain provides a minimum shtk version.
    find_shtk_system = use_extension("@rules_shtk//:extensions.bzl", "find_shtk_system")
    find_shtk_system.settings(min_version = "1.7")
    use_repo(find_shtk_system, "shtk_autoconf")
    register_toolchains("@shtk_autoconf//:toolchain")

    # Load a system-provided shtk from the given location.
    find_shtk_system = use_extension("@rules_shtk//:extensions.bzl", "find_shtk_system")
    find_shtk_system.settings(shtk_path = "/usr/local/bin/shtk")
    use_repo(find_shtk_system, "shtk_autoconf")
    register_toolchains("@shtk_autoconf//:toolchain")
    ```

## Set up with legacy workspace

Legacy workspaces are still supported but not documented.  You can use the
[workspace examples](examples/workspace) as a reference for what you need to do.

## Usage

You can find fully-defined examples under [examples](examples).  This section
just gives you a quick overview of what you can do.

Define binaries like this:

```python
load("@rules_shtk//:rules.bzl", "shtk_binary")

shtk_binary(
    name = "hello",
    src = "hello.sh",
)
```

And tests like this:

```python
load("@rules_shtk//:rules.bzl", "shtk_test")

shtk_test(
    name = "hello_test",
    src = "hello_test.sh",
    data = [":hello"],
)
```
