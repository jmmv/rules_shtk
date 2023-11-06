# rules\_shtk: Bazel rules for shtk

This directory contains Bazel rules to build shtk scripts and run shtk tests
from Bazel.

The major selling point of these rules is to leverage shtk to write and run
end-to-end unit tests for binaries you build with Bazel, especially if those
binaries are CLI tools.  Shell scripts are uniquely suited to drive the
execution of tools, and shtk's `unittest` module provides facilities to define
test cases and fixtures, and to assert the behavior of command invocations.

For more information about shtk, visit <https://shtk.jmmv.dev/>.

## Set up

To get started, add the following entry to your `MODULE.bazel`:

```python
bazel_dep(name = "rules_shtk", version = "1.7.0")
# This override is necessary until `rules_shtk` is added to the Bazel Central Registry.
archive_override(
    module_name = "rules_shtk",
    integrity = "sha256-+keJHyfY1ZYJcys03IgCAzG4G5dny9cglP7Bvor0rfw=",
    urls = [
        "https://github.com/jmmv/rules_shtk/releases/download/rules_shtk-1.7.0/rules_shtk-1.7.0.tar.gz",
    ],
    strip_prefix = "rules_shtk-1.7.0",
)
```

Then, update your `WORKSPACE.bazel` file to load an shtk toolchain.  You can
choose between:

*   `shtk_dist`, which downloads the version of shtk corresponding to the
    rules and builds it.  This is typically what you should use, especially if
    all you care about is building and running tests from within Bazel.

    ```python
    load("@rules_shtk//:repositories.bzl", "shtk_dist")

    # Use the shtk release that matches these rules (if these rules are version
    # 1.7.0, then this uses shtk 1.7).
    shtk_dist()
    ```

*   `shtk_system`, which discovers an shtk toolchain installed on the system.
    Use this if you need to install the built scripts.  This macro accepts
    optional arguments to configure its auto-discovery process.

    ```python
    load("@rules_shtk//:repositories.bzl", "shtk_system")

    # Auto-discover the system-provided shtk by looking for shtk(1) in the PATH.
    shtk_system()

    # Auto-discover the system-provided shtk by looking for shtk(1) in the PATH
    # and ensure that the discovered toolchain provides a minimum shtk version.
    shtk_system(min_version = "1.7")

    # Load a system-provided shtk from the given location.
    shtk_system(shtk_path = "/usr/local/bin/shtk")
    ```

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
