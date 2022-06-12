#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class AdspSection(Section):
	name = "ADSP"
	interfaces = [
		"vendor.qti.adsprpc",
	]
	binaries = [
		"adsprpcd",
	]
	libraries = [
		"libadsprpc",
		"libadsp_default_listener",
	]

class AdspModulesSection(Section):
	name = "ADSP modules"
	folders = [
		"lib/rfsa/adsp",
		"lib64/rfsa/adsp",
	]

register_section(AdspSection)
register_section(AdspModulesSection)
