#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class CitSection(Section):
	name = "CIT"
	interfaces = [
		"vendor.xiaomi.cit.bluetooth",
		"vendor.xiaomi.cit.wifi",
		"vendor.xiaomi.hardware.citsensorservice",
		"vendor.xiaomi.hardware.citvendorservice",
	]

register_section(CitSection)
