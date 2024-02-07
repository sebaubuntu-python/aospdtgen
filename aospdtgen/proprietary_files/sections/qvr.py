#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class QvrSection(Section):
	name = "QVR"
	interfaces = [
		"vendor.qti.hardware.qvr",
	]
	binaries = [
		"qvrdatalogger",
		"qvrservice",
		"qvrservicetest",
		"qvrservicetest64",
	]
	folders = [
		"etc/qvr",
	]

register_section(QvrSection)
