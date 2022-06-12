#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class RadioSection(Section):
	name = "Radio"
	interfaces = [
		"android.hardware.radio",
		"mtkfusionrild",
		"qcrild",
		"vendor.mediatek.hardware.mtkradioex",
		"vendor.mediatek.hardware.radio",
		"vendor.qti.hardware.radio.am",
		"vendor.qti.hardware.radio.atcmdfwd",
		"vendor.qti.hardware.radio.internal.deviceinfo",
		"vendor.qti.hardware.radio.lpa",
		"vendor.qti.hardware.radio.qcrilhook",
		"vendor.qti.hardware.radio.qtiradio",
		"vendor.qti.hardware.radio.uim",
		"vendor.qti.rmt_storage",
		"vendor.qti.tftp",
	]
	hardware_modules = [
		"radio",
	]
	apps = [
		"IWlanService",
		"QtiTelephonyService",
		"qcrilmsgtunnel",
	]
	binaries = [
		"ATFWD-daemon",
		"adpl",
		"ks",
		"mdm_helper",
		"netmgrd",
		"pd-mapper",
		"port-bridge",
		"qrtr-cfg",
		"qrtr-lookup",
		"qrtr-ns",
		"qti",
		"rmt_storage",
		"ssgtzd",
		"tftp_server",
	]
	filenames = [
		"init-qcril-data.rc",
	]
	folders = [
		"radio/qcril_database",
	]
	patterns = [
		"etc/init/data.*.\.rc",
		"etc/seccomp_policy/atfwd(@[0-9]+\.[0-9]+)?.policy",
	]

class RadioImsSection(Section):
	name = "Radio (IMS)"
	interfaces = [
		"com.qualcomm.qti.imscmservice",
		"com.qualcomm.qti.uceservice",
		"vendor.qti.hardware.radio.ims",
		"vendor.qti.ims.callcapability",
		"vendor.qti.ims.callinfo",
		"vendor.qti.ims.factory",
		"vendor.qti.ims.rcsconfig",
		"vendor.qti.imsrtpservice",
	]
	apps = [
		"ims",
	]
	binaries = [
		"ims_rtp_daemon",
		"imsdatadaemon",
		"imsqmidaemon",
		"imsrcsd",
	]
	libraries = [
		"lib-rcsconfig",
		"lib-siputility",
		"lib-uceservice",
	]
	filenames = [
		"imsrtp.policy",
	]
	patterns = [
		"lib(64)?/lib-ims.*.\.so",
	]

register_section(RadioSection)
register_section(RadioImsSection)
