#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class DspSection(Section):
	name = "DSP"
	interfaces = [
		"vendor.qti.hardware.dsp",
	]
	binaries = [
		"dspservice",
	]
	filenames = [
		"vendor.qti.hardware.dsp.policy",
	]

register_section(DspSection)
