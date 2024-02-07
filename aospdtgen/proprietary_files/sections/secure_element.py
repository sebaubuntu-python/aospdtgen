#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class SecureElementSection(Section):
	name = "Secure element"
	interfaces = [
		"android.hardware.secure_element",
		"vendor.qti.secure_element",
	]

class SecureElementPowerManagerSection(Section):
	name = "Secure element (power manager)"
	interfaces = [
		"vendor.qti.esepowermanager",
	]

register_section(SecureElementSection)
register_section(SecureElementPowerManagerSection)
