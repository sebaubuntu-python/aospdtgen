#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class VibratorSection(Section):
	name = "Vibrator"
	interfaces = [
		"android.hardware.vibrator",
		"vendor.qti.hardware.vibrator",
	]
	hardware_modules = [
		"vibrator",
	]

class VibratorXiaomiSection(Section):
	name = "Vibrator (Xiaomi)"
	interfaces = [
		"vendor.xiaomi.hardware.vibratorfeature",
	]

class VibratorFirmwareSection(Section):
	name = "Vibrator firmware"
	patterns = [
		"firmware/.*(rtp|RTP)\.bin",
		"firmware/aw8697.*\.bin",
	]

register_section(VibratorSection)
register_section(VibratorXiaomiSection)
register_section(VibratorFirmwareSection)
