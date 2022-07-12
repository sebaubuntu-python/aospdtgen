#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from sebaubuntu_libs.libandroid.props.utils import get_partition_props
from typing import List

IGNORED_PROPS: List[str] = []
"""A list of build props that should be ignored because automatically generated."""

# Build info
IGNORED_PROPS.extend(get_partition_props("ro.{}build.date", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.date.utc", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.fingerprint", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.flavor", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.host", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.id", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.keys", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.security_patch", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.tags", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.type", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.user", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.all_codenames", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.base_os", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.codename", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.incremental", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.min_supported_target_sdk", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.preview_sdk", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.preview_sdk_fingerprint", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.release", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.release_or_codename", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.sdk", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}build.version.security_patch", add_empty=True))

# Product info
IGNORED_PROPS.extend(get_partition_props("ro.product.{}brand", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.product.{}device", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.product.{}manufacturer", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.product.{}model", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.product.{}name", add_empty=True))

# ABI list
IGNORED_PROPS.extend(get_partition_props("ro.{}product.cpu.abi", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}product.cpu.abilist", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}product.cpu.abilist32", add_empty=True))
IGNORED_PROPS.extend(get_partition_props("ro.{}product.cpu.abilist64", add_empty=True))

# Screen density
IGNORED_PROPS.append("ro.sf.lcd_density")

# Treble/VNDK
IGNORED_PROPS.extend(get_partition_props("ro.{}vndk.version", add_empty=True))
IGNORED_PROPS.append("ro.treble.enabled")

# Bionic
IGNORED_PROPS.append("ro.bionic.arch")
IGNORED_PROPS.append("ro.bionic.cpu_variant")
IGNORED_PROPS.append("ro.bionic.2nd_arch")
IGNORED_PROPS.append("ro.bionic.2nd_cpu_variant")

# Platform
IGNORED_PROPS.append("ro.board.platform")

# Partitions
IGNORED_PROPS.append("ro.boot.dynamic_partitions")
IGNORED_PROPS.append("ro.build.ab_update")
IGNORED_PROPS.append("ro.build.system_root_image")
IGNORED_PROPS.append("ro.virtual_ab.enabled")

# Pixel format
IGNORED_PROPS.append("ro.minui.pixel_format")

# First API level
IGNORED_PROPS.append("ro.product.first_api_level")

# Zygote
IGNORED_PROPS.append("ro.zygote")

# Dalvik
IGNORED_PROPS.append("dalvik.vm.isa.arm.features")
IGNORED_PROPS.append("dalvik.vm.isa.arm.variant")
IGNORED_PROPS.append("dalvik.vm.isa.arm64.features")
IGNORED_PROPS.append("dalvik.vm.isa.arm64.variant")
IGNORED_PROPS.append("dalvik.vm.isa.x86.features")
IGNORED_PROPS.append("dalvik.vm.isa.x86.variant")
IGNORED_PROPS.append("dalvik.vm.isa.x86_64.features")
IGNORED_PROPS.append("dalvik.vm.isa.x86_64.variant")

# Characteristics
IGNORED_PROPS.append("ro.build.characteristics")

# Board
IGNORED_PROPS.append("ro.product.board")

# Locale
IGNORED_PROPS.append("ro.product.locale")

# APEX
IGNORED_PROPS.append("ro.apex.updatable")

# Vulkan
IGNORED_PROPS.append("ro.hwui.use_vulkan")
