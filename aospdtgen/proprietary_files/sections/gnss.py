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
	hardware_modules = [
		"gps",
	]
	binaries = [
		"loc_launcher",
		"lowi-server",
		"slim_daemon",
		"xtra-daemon",
		"xtwifi-client",
		"xtwifi-inet-agent",
	]

class GnssConfigsSection(Section):
	name = "GNSS configs"
	filenames = [
		"apdr.conf",
		"flp.conf",
		"gps.conf",
		"izat.conf",
		"lowi.conf",
		"sap.conf",
		"xtwifi.conf",
	]
	folders = [
		"etc/gnss",
	]

register_section(GnssSection)
register_section(GnssConfigsSection)
