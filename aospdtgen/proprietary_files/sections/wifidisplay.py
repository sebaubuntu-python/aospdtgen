#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class WifiDisplaySection(Section):
	name = "Wi-Fi Display"
	interfaces = [
		"com.qualcomm.qti.wifidisplayhal",
		"vendor.qti.hardware.sigma_miracast",
		"vendor.qti.hardware.wifidisplaysession",
	]
	apps = [
		"WfdService",
	]
	binaries = [
		"wfdhdcphalservice",
		"wfdservice",
		"wfdvndservice",
		"wifidisplayhalservice",
	]
	filenames = [
		"wifidisplayhalservice.policy",
	]
	patterns = [
		"etc/seccomp_policy/wfd.*.service\.policy",
	]

register_section(WifiDisplaySection)
