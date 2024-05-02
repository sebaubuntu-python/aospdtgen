#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class UsbSection(Section):
	name = "USB"
	interfaces = [
		"android.hardware.usb",
	]
	properties_prefixes = {
		"vendor.usb.": False,
	}

register_section(UsbSection)
