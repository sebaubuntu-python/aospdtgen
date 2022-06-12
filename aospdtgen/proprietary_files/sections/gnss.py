#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class GnssSection(Section):
	name = "GNSS"
	interfaces = [
		"android.hardware.gnss",
		"vendor.qti.gnss",
	]
	binaries = [
		"loc_launcher",
		"lowi-server",
		"slim_daemon",
		"xtra-daemon",
		"xtwifi-client",
		"xtwifi-inet-agent",
	]

register_section(GnssSection)
