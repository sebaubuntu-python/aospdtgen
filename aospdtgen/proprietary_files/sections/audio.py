#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class AudioSection(Section):
	name = "Audio"
	interfaces = [
		"android.hardware.audio",
		"android.hardware.audio.effect",
		"vendor.qti.hardware.audiohalext",
	]
	hardware_modules = [
		"audio.primary",
		"audio.r_submix",
		"audio.usb",
	]

class AudioFxModulesSection(Section):
	name = "Audio (FX modules)"
	folders = [
		"lib/soundfx",
		"lib64/soundfx",
	]

class AudioConfigsSection(Section):
	name = "Audio configs"
	filenames = [
		"audio_io_policy.conf",
		"audio_tuning_mixer.txt",
		"default_volume_tables.xml",
	]
	folders = [
		"etc/audio",
	]
	patterns = [
		"etc/audio_configs.*\.xml",
		"etc/audio_effects.*\.(conf|xml)",
		"etc/audio_platform_info.*\.xml",
		"etc/.*audio_policy.*\.xml",
		"etc/mixer_paths.*\.xml",
		"etc/sound_trigger_.*\.xml",
	]

register_section(AudioSection)
register_section(AudioFxModulesSection)
register_section(AudioConfigsSection)
