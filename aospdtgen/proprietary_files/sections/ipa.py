#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class IpaSection(Section):
	name = "IPA"
	binaries = [
		"ipacm",
		"ipacm-diag",
	]
	libraries = [
		"libipanat",
		"liboffloadhal",
	]
	filenames = [
		"IPACM_cfg.xml",
	]

class IpaFirmwareSection(Section):
	name = "IPA firmware"
	filenames = [
		"ipa_fws.rc",
	]
	patterns = [
		"firmware/.*ipa_(fws|uc)*.",
	]

register_section(IpaSection)
register_section(IpaFirmwareSection)
