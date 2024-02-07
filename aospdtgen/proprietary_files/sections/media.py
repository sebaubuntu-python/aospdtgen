#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class MediaSection(Section):
	name = "Media"
	interfaces = [
		"android.hardware.media.c2",
		"android.hardware.media.omx",
		"vendor.qti.hardware.qconfig",
		"vendor.qti.hardware.vpp",
		"vendor.qti.media.c2",
	]
	binaries = [
		"qconfigservice",
		"vppservice",
	]
	filenames = [
		"c2_manifest_vendor.xml",
		"mediacodec.policy",
	]
	patterns = [
		"etc/seccomp_policy/codec2.vendor.*.-arm\.policy",
		"lib(64)?/libMtkOmx.*\.so",
		"lib(64)?/libOmx.*\.so",
		"lib(64)?/libstagefright.*\.so",
	]

class MediaDolbySection(Section):
	name = "Media (Dolby)"
	interfaces = [
		"vendor.dolby.dms",
		"vendor.dolby.hardware.dms",
		"vendor.dolby.media.c2",
		"vendor.dolby_sp.hardware.dmssp",
		"vendor.dolby_sp.media.c2",
	]
	libraries = [
		"libdapparamstorage",
		"libdeccfg",
	]
	filenames = [
		"dolby_vision.cfg",
	]
	folders = [
		"etc/dolby",
	]
	patterns = [
		"lib(64)?/libdolby.*\.so",
	]

class MediaOZOAudioSection(Section):
	name = "Media (OZO Audio)"
	interfaces = [
		"vendor.ozoaudio.media.c2",
	]

class MediaConfigsSection(Section):
	name = "Media configs"
	patterns = [
		"etc/media_codecs.*\.xml",
		"etc/media_profiles.*\.xml",
	]

register_section(MediaSection)
register_section(MediaDolbySection)
register_section(MediaOZOAudioSection)
register_section(MediaConfigsSection)
