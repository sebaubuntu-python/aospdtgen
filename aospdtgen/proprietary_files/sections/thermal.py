#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class ThermalSection(Section):
	name = "Thermal"
	interfaces = [
		"android.hardware.thermal",
	]
	hardware_modules = [
		"thermal",
	]
	binaries = [
		"thermal-engine",
	]
	libraries = [
		"libthermalclient",
	]

class ThermalXiaomiSection(Section):
	name = "Thermal (Xiaomi)"
	binaries = [
		"mi_thermald",
	]

class ThermalConfigsSection(Section):
	name = "Thermal configs"
	patterns = [
		"etc/thermal.*.\.conf",
	]

register_section(ThermalSection)
register_section(ThermalXiaomiSection)
register_section(ThermalConfigsSection)
