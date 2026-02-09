#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class RadioSection(Section):
	name = "Radio"
	interfaces = [
		"android.hardware.radio",
		"mtkfusionrild",
		"qcrild",
		"qcrilNrd",
		"rild",
		"vendor.mediatek.hardware.mtkradioex",
		"vendor.mediatek.hardware.nwk_opt",
		"vendor.mediatek.hardware.radio",
		"vendor.oplus.hardware.appradioaidl",
		"vendor.oplus.hardware.esim",
		"vendor.oplus.hardware.radio",
		"vendor.qti.hardware.embmssl",
		"vendor.qti.hardware.embmsslaidl",
		"vendor.qti.hardware.radio.am",
		"vendor.qti.hardware.radio.atcmdfwd",
		"vendor.qti.hardware.radio.common",
		"vendor.qti.hardware.radio.internal.deviceinfo",
		"vendor.qti.hardware.radio.lpa",
		"vendor.qti.hardware.radio.qcrilhook",
		"vendor.qti.hardware.radio.qtiradio",
		"vendor.qti.hardware.radio.qtiradioconfig",
		"vendor.qti.hardware.radio.uim",
		"vendor.qti.hardware.radio.uim_remote_client",
		"vendor.qti.hardware.radio.uim_remote_server",
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
		"ccci_mdinit",
		"ccci_rpcd",
		"gsm0710muxd",
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
		"xcap",
	]
	filenames = [
		"init-qcril-data.rc",
		"init.md_apps.rc",
	]
	folders = [
		"etc/qcril_database",
		"radio/qcril_database",
	]
	patterns = [
		"etc/init/init.ccci.*\.rc",
		"etc/init/data.*.\.rc",
		"etc/seccomp_policy/atfwd(@[0-9]+\.[0-9]+)?.policy",
	]
	properties_prefixes = {
		"persist.radio.": False,
		"persist.rild.": False,
		"persist.vendor.mdm_helper.": False,
		"persist.vendor.radio.": False,
		"ril.": False,
		"rild.": False,
		"ro.radio.": False,
		"ro.telephony.": False,
		"telephony.": False,
	}

class RadioImsSection(Section):
	name = "Radio (IMS)"
	interfaces = [
		"com.qualcomm.qti.imscmservice",
		"com.qualcomm.qti.uceservice",
		"vendor.mediatek.hardware.rcs",
		"vendor.mediatek.hardware.videotelephony",
		"vendor.oplus.hardware.ims",
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
		"bip",
		"charon",
		"epdg_wod",
		"ims_rtp_daemon",
		"imsdatadaemon",
		"imsqmidaemon",
		"imsrcsd",
		"ipsec_mon",
		"rcs_volte_stack",
		"starter",
		"stroke",
		"volte_clientapi_ua",
		"volte_imcb",
		"volte_imsm_93",
		"volte_md_status",
		"volte_rcs_ua",
		"volte_stack",
		"volte_ua",
		"vtservice_hidl",
	]
	libraries = [
		"lib-rcsconfig",
		"lib-siputility",
		"lib-uceservice",
	]
	filenames = [
		"imsrtp.policy",
		"init.wod.rc",
	]
	patterns = [
		"lib(64)?/lib-ims.*.\.so",
	]
	properties_prefixes = {
		"persist.vendor.ims.": False,
	}

register_section(RadioSection)
register_section(RadioImsSection)
