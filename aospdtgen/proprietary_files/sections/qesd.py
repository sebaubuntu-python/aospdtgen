#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class QesdSection(Section):
	name = "QESD"
	interfaces = [
		"vendor.qti.qesdhal",
		"vendor.qti.qesdhalaidl",
		"vendor.qti.qesdsys",
	]
	binaries = [
		"perf_qesdk_client",
		"qesdk-manager",
		"sensors-qesdk",
	]

register_section(QesdSection)
