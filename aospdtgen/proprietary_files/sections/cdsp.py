#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class CdspSection(Section):
	name = "CDSP"
	interfaces = [
		"vendor.qti.cdsprpc",
	]
	binaries = [
		"cdsprpcd",
	]
	libraries = [
		"libcdsprpc",
		"libcdsp_default_listener",
		"libfastcvdsp_stub",
		"libfastcvopt",
	]

register_section(CdspSection)
