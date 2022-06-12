#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class DrmSection(Section):
	name = "DRM"
	interfaces = [
		"android.hardware.drm",
	]
	libraries = [
		"liboemcrypto",
	]
	folders = [
		"lib/mediacas",
		"lib/mediadrm",
		"lib64/mediacas",
		"lib64/mediadrm",
	]

class DrmQseeSection(Section):
	name = "DRM (Qualcomm Secure Execution Environment)"
	interfaces = [
		"vendor.qti.hardware.qseecom",
	]
	binaries = [
		"qseecomd",
	]
	libraries = [
		"libQSEEComAPI",
	]

class DrmQteeSection(Section):
	name = "DRM (Qualcomm Trusted Execution Environment)"
	interfaces = [
		"vendor.qti.hardware.qteeconnector",
	]

register_section(DrmSection)
register_section(DrmQseeSection)
register_section(DrmQteeSection)
