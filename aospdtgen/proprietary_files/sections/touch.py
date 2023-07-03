#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class TouchHBTPSection(Section):
	name = "Touch (HBTP)"
	interfaces = [
		"vendor.qti.hardware.improvetouch.touchcompanion",
	]
	binaries = [
		"hbtp_daemon",
	]
	folders = [
		"etc/hbtp",
	]

class TouchTouchfeatureSection(Section):
	name = "Touch (Touchfeature)"
	interfaces = [
		"vendor.xiaomi.hardware.touchfeature",
	]

register_section(TouchHBTPSection)
register_section(TouchTouchfeatureSection)
