#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class RenderscriptSection(Section):
	name = "RenderScript"
	interfaces = [
		"android.hardware.renderscript",
	]
	libraries = [
		"libRSDriver_adreno",
		"librs_adreno",
		"librs_adreno_sha1",
	]

register_section(RenderscriptSection)
