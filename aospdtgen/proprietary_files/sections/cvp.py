#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class CvpSection(Section):
	name = "CVP"
	interfaces = [
		"vendor.qti.hardware.cvp",
	]

class CvpFirmwareSection(Section):
	name = "CVP firmware"
	patterns = [
		"(.*/)?firmware/evass\..*",
		"(.*/)?firmware/evass-lt\..*",
	]

register_section(CvpSection)
register_section(CvpFirmwareSection)
