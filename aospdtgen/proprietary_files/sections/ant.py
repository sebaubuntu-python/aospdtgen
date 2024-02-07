#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class AntSection(Section):
	name = "ANT"
	interfaces = [
		"com.dsi.ant",
		"com.qualcomm.qti.ant",
		"vendor.xiaomi.hardware.antdtx",
	]

class AntFirmwareSection(Section):
	name = "ANT firmware"
	patterns = [
		"(.*/)?firmware/antdtx\..*",
	]

register_section(AntSection)
register_section(AntFirmwareSection)
