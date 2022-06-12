#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class FaceSection(Section):
	name = "Face"
	interfaces = [
		"android.hardware.biometrics.face",
	]

register_section(FaceSection)
