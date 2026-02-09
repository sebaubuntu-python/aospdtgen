#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class SoundtriggerSection(Section):
	name = "Soundtrigger"
	interfaces = [
		"android.hardware.soundtrigger",
		"android.hardware.soundtrigger3",
		"vendor.qti.voiceprint",
	]
	hardware_modules = [
		"sound_trigger",
	]
	properties_prefixes = {
		"ro.vendor.audio.soundtrigger": False,
	}

register_section(SoundtriggerSection)
