#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class ChargerSection(Section):
	name = "Charger"
	interfaces = [
		"vendor.qti.hardware.charger_monitor",
	]
	binaries = [
		"hvdcp_opti",
		"init.qti.chg_policy.sh",
	]
	filenames = [
		"charger_fstab.qti",
	]

class ChargerXiaomiSection(Section):
	name = "Charger (Xiaomi)"
	interfaces = [
		"vendor.xiaomi.hardware.micharge",
	]
	binaries = [
		"batterysecret",
	]

register_section(ChargerSection)
register_section(ChargerXiaomiSection)
