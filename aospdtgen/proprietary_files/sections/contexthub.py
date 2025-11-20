#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class ContextHubSection(Section):
	name = "Context hub"
	interfaces = [
		"android.hardware.contexthub",
	]

register_section(ContextHubSection)
