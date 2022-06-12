#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class DisplaySection(Section):
	name = "Display"
	interfaces = [
		"android.hardware.graphics.allocator",
		"android.hardware.graphics.bufferqueue",
		"android.hardware.graphics.composer",
		"android.hardware.graphics.mapper",
		"android.hardware.memtrack",
		"vendor.display.color",
		"vendor.display.config",
		"vendor.display.postproc",
		"vendor.qti.hardware.display.allocator",
		"vendor.qti.hardware.display.composer",
		"vendor.qti.hardware.display.mapper",
		"vendor.qti.hardware.display.mapperextensions",
		"vendor.qti.hardware.qdutils_disp",
	]
	hardware_modules = [
		"copybit",
		"gralloc",
		"hwcomposer",
		"memtrack",
		"vulkan",
	]
	folders = [
		"lib/egl",
		"lib64/egl",
	]

class DisplayConfigsSection(Section):
	name = "Display configs"
	patterns = [
		"etc/ltm_*",
		"etc/mdss_*",
		"etc/qdcm_*",
	]

class DisplayFirmwareSection(Section):
	name = "Display (firmware)"
	patterns = [
		"firmware/a[0-9]+_.*\..*",
	]

class DisplayXiaomiSection(Section):
	name = "Display (Xiaomi)"
	interfaces = [
		"vendor.xiaomi.hardware.displayfeature",
	]
	hardware_modules = [
		"displayfeature",
	]

register_section(DisplaySection)
register_section(DisplayConfigsSection)
register_section(DisplayFirmwareSection)
register_section(DisplayXiaomiSection)
