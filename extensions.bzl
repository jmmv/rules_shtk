# Copyright 2025 Julio Merino
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

load(":repositories.bzl", "shtk_dist", "shtk_system")

_settings_tag = tag_class(
    attrs = {
        "min_version": attr.string(
            mandatory = False,
            doc = "Minimum version of shtk(1) needed.",
        ),
        "shtk_path": attr.string(
            mandatory = False,
            doc = "Path to the shtk(1) binary if a specific one is desired.",
        ),
    },
)

def _find_shtk_system(module_ctx):
    kwargs = {}
    for module in module_ctx.modules:
        for tag in module.tags.settings:
            kwargs["min_version"] = tag.min_version
            kwargs["shtk_path"] = tag.shtk_path

    shtk_system(register = False, **kwargs)

find_shtk_system = module_extension(
    implementation = _find_shtk_system,
    tag_classes = {
        "settings": _settings_tag,
    },
)

def _fetch_shtk_dist(module_ctx):
    shtk_dist(register = False)

    # Borrowed from:
    # https://github.com/bazelbuild/platforms/blob/5cf94563e35494b0dab15435868dd7f9e3cab2c8/host/extension.bzl#L70
    #
    # module_ctx.extension_metadata has the paramater `reproducible` as of Bazel
    # 7.1.0. We can't test for it directly and would ideally use bazel_features
    # to check for it, but adding a dependency on it would require complicating
    # the WORKSPACE setup. Thus, test for it by checking the availability of
    # another feature introduced in 7.1.0.
    if hasattr(module_ctx, "extension_metadata") and hasattr(module_ctx, "watch"):
        return module_ctx.extension_metadata(reproducible = True)
    else:
        return None

fetch_shtk_dist = module_extension(
    implementation = _fetch_shtk_dist,
)
