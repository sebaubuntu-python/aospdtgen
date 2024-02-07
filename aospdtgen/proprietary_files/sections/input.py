#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class InputSection(Section):
	name = "Input"
	interfaces = [
		"android.hardware.input",
	]

class InputMotorolaSection(Section):
	name = "Input (Motorola)"
	interfaces = [
		"motorola.hardware.input",
	]

register_section(InputSection)
register_section(InputMotorolaSection)
