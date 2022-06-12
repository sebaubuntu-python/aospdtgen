#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class QccSection(Section):
	name = "QCC"
	interfaces = [
		"vendor.qti.hardware.qccsyshal",
		"vendor.qti.hardware.qccvndhal",
	]

register_section(QccSection)
