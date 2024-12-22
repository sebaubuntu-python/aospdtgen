#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class NVRAMSection(Section):
	name = "NVRAM"
	interfaces = [
		"vendor.mediatek.hardware.nvram",
	]
	binaries = [
		"fuelgauged_nvram",
		"nvram_daemon",
	]
	filenames = [
		"fuelgauged_nvram_init.rc",
	]

register_section(NVRAMSection)

