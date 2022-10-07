# Copyright 2021 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Implementation of watchOS test rules."""

load(
    "@build_bazel_rules_apple//apple/internal/testing:apple_test_rule_support.bzl",
    "apple_test_rule_support",
)
load(
    "@build_bazel_rules_apple//apple/internal/testing:apple_test_bundle_support.bzl",
    "apple_test_bundle_support",
)
load(
    "@build_bazel_rules_apple//apple/internal:apple_product_type.bzl",
    "apple_product_type",
)
load(
    "@build_bazel_rules_apple//apple/internal:rule_attrs.bzl",
    "rule_attrs",
)
load(
    "@build_bazel_rules_apple//apple/internal:rule_factory.bzl",
    "rule_factory",
)
load(
    "@build_bazel_rules_apple//apple/internal/aspects:framework_provider_aspect.bzl",
    "framework_provider_aspect",
)
load(
    "@build_bazel_rules_apple//apple/internal/aspects:resource_aspect.bzl",
    "apple_resource_aspect",
)
load(
    "@build_bazel_rules_apple//apple:providers.bzl",
    "AppleBundleInfo",
    "WatchosApplicationBundleInfo",
    "WatchosXcTestBundleInfo",
)

_WATCHOS_TEST_HOST_PROVIDERS = [[AppleBundleInfo, WatchosApplicationBundleInfo]]

def _watchos_ui_test_bundle_impl(ctx):
    """Implementation of watchos_ui_test."""
    return apple_test_bundle_support.apple_test_bundle_impl(
        ctx = ctx,
        product_type = apple_product_type.ui_test_bundle,
    ) + [
        WatchosXcTestBundleInfo(),
    ]

def _watchos_unit_test_bundle_impl(ctx):
    """Implementation of watchos_unit_test."""
    return apple_test_bundle_support.apple_test_bundle_impl(
        ctx = ctx,
        product_type = apple_product_type.unit_test_bundle,
    ) + [
        WatchosXcTestBundleInfo(),
    ]

def _watchos_ui_test_impl(ctx):
    """Implementation of watchos_ui_test."""
    return apple_test_rule_support.apple_test_rule_impl(ctx, "xcuitest") + [
        WatchosXcTestBundleInfo(),
    ]

def _watchos_unit_test_impl(ctx):
    """Implementation of watchos_unit_test."""
    return apple_test_rule_support.apple_test_rule_impl(ctx, "xctest") + [
        WatchosXcTestBundleInfo(),
    ]

# Declare it with an underscore to hint that this is an implementation detail in bazel query-s.
_watchos_internal_ui_test_bundle = rule_factory.create_apple_bundling_rule_with_attrs(
    implementation = _watchos_ui_test_bundle_impl,
    doc = "Builds and bundles an watchOS UI Test Bundle. Internal target not to be depended upon.",
    attrs = [
        rule_attrs.binary_linking_attrs(
            deps_cfg = apple_common.multi_arch_split,
            extra_deps_aspects = [
                apple_resource_aspect,
                framework_provider_aspect,
            ],
            is_test_supporting_rule = True,
            requires_legacy_cc_toolchain = True,
        ),
        rule_attrs.bundle_id_attrs(is_mandatory = False),
        rule_attrs.common_bundle_attrs,
        rule_attrs.common_tool_attrs,
        rule_attrs.device_family_attrs(
            allowed_families = rule_attrs.defaults.allowed_families.watchos,
            is_mandatory = False,
        ),
        rule_attrs.entitlements_attrs,
        rule_attrs.infoplist_attrs(
            default_infoplist = rule_attrs.defaults.test_bundle_infoplist,
        ),
        rule_attrs.platform_attrs(
            add_environment_plist = True,
            platform_type = "watchos",
        ),
        rule_attrs.provisioning_profile_attrs(),
        rule_attrs.test_bundle_attrs,
        rule_attrs.test_host_attrs(
            aspects = rule_attrs.aspects.test_host_aspects,
            is_mandatory = True,
            providers = _WATCHOS_TEST_HOST_PROVIDERS,
        ),
    ],
)

# Alias to reference it in apple_test_assembler.assemble(...) from another package via load(...).
watchos_internal_ui_test_bundle = _watchos_internal_ui_test_bundle

watchos_ui_test = rule_factory.create_apple_test_rule(
    implementation = _watchos_ui_test_impl,
    doc = "watchOS UI Test rule.",
    platform_type = "watchos",
)

# Declare it with an underscore to hint that this is an implementation detail in bazel query-s.
_watchos_internal_unit_test_bundle = rule_factory.create_apple_bundling_rule_with_attrs(
    implementation = _watchos_unit_test_bundle_impl,
    doc = "Builds and bundles an watchOS Unit Test Bundle. Internal target not to be depended upon.",
    attrs = [
        rule_attrs.binary_linking_attrs(
            deps_cfg = apple_common.multi_arch_split,
            extra_deps_aspects = [
                apple_resource_aspect,
                framework_provider_aspect,
            ],
            is_test_supporting_rule = True,
            requires_legacy_cc_toolchain = True,
        ),
        rule_attrs.bundle_id_attrs(is_mandatory = False),
        rule_attrs.common_bundle_attrs,
        rule_attrs.common_tool_attrs,
        rule_attrs.device_family_attrs(
            allowed_families = rule_attrs.defaults.allowed_families.watchos,
            is_mandatory = False,
        ),
        rule_attrs.entitlements_attrs,
        rule_attrs.infoplist_attrs(
            default_infoplist = rule_attrs.defaults.test_bundle_infoplist,
        ),
        rule_attrs.platform_attrs(
            add_environment_plist = True,
            platform_type = "watchos",
        ),
        rule_attrs.provisioning_profile_attrs(),
        rule_attrs.test_bundle_attrs,
        rule_attrs.test_host_attrs(
            aspects = rule_attrs.aspects.test_host_aspects,
            providers = _WATCHOS_TEST_HOST_PROVIDERS,
        ),
    ],
)

# Alias to reference it in apple_test_assembler.assemble(...) from another package via load(...).
watchos_internal_unit_test_bundle = _watchos_internal_unit_test_bundle

watchos_unit_test = rule_factory.create_apple_test_rule(
    implementation = _watchos_unit_test_impl,
    doc = "watchOS Unit Test rule.",
    platform_type = "watchos",
)
