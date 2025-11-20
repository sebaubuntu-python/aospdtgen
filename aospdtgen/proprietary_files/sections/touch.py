#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class TouchHbtpSection(Section):
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

class TouchOplusSection(Section):
	name = "Touch (oplus)"
	interfaces = [
		"vendor-oplus-hardware-touch",
	]

class TouchXiaomiSection(Section):
	name = "Touch (Xiaomi)"
	interfaces = [
		"vendor.xiaomi.hardware.touchfeature",
	]
	properties_prefixes = {
		"ro.vendor.touchfeature.": False,
	}

class TouchFirmwareSection(Section):
	name = "Touch firmware"
	folders = [
		"firmware/tp",
	]

register_section(TouchHbtpSection)
register_section(TouchOplusSection)
register_section(TouchXiaomiSection)
register_section(TouchFirmwareSection)
