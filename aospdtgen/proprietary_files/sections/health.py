#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class HealthSection(Section):
	name = "Health"
	interfaces = [
		"android.hardware.health",
		"motorola.hardware.health",
		"motorola.hardware.health.storage",
		"motorola.hardware.wireless.wlc",
		"vendor.oplus.hardware.charger",
		"vendor-oplus-hardware-charger",
		"vendor.qti.hardware.charger_monitor",
		"vendor.xiaomi.hardware.micharge",
	]
	binaries = [
		"batterysecret",
		"hvdcp_opti",
		"init.qti.chg_policy.sh",
		"wlschgd",
	]
	filenames = [
		"charger_fstab.qti",
	]

class HealthFirmwareSection(Section):
	name = "Health firmware"
	folders = [
		"firmware/fastchg",
	]

register_section(HealthSection)
register_section(HealthFirmwareSection)
