#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class PasrSection(Section):
	name = "PASR"
	interfaces = [
		"vendor.qti.memory.pasrmanager",
		"vendor.qti.power.pasrmanager",
	]
	apps = [
		"pasrservice",
	]

register_section(PasrSection)
