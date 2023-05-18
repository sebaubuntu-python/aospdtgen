#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class HealthSection(Section):
	name = "Health"
	interfaces = [
		"android.hardware.health",
		"motorola.hardware.health",
		"motorola.hardware.health.storage",
	]

class HealthWlcSection(Section):
	name = "Health (wireless charging)"
	interfaces = [
		"motorola.hardware.wireless.wlc",
	]

register_section(HealthSection)
register_section(HealthWlcSection)
