#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class ConfigstoreSection(Section):
	name = "Configstore"
	interfaces = [
		"android.hardware.configstore",
		"vendor.qti.hardware.capabilityconfigstore",
	]
	folders = [
		"etc/configstore",
	]

register_section(ConfigstoreSection)
