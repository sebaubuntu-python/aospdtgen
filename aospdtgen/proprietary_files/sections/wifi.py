#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class WifiSection(Section):
	name = "Wi-Fi"
	interfaces = [
		"android.hardware.wifi",
		"vendor.asus.wifi.netutil",
		"vendor.asus.wifi.rttutil",
		"vendor.ims.wifiantennamode",
		"vendor.mediatek.hardware.wifi.hostapd",
		"vendor.mediatek.hardware.wifi.supplicant",
		"vendor.oplus.hardware.wifi",
		"vendor.oplus.hardware.wifi-aidl",
		"vendor.qti.hardware.fstman",
		"vendor.qti.hardware.wifi.hostapd",
		"vendor.qti.hardware.wifi.keystore",
		"vendor.qti.hardware.wifi.supplicant",
		"vendor.qti.hardware.wifi.wifilearner",
		"vendor.qti.hardware.wigig.netperftuner",
		"vendor.qti.hardware.wigig.supptunnel",
	]
	binaries = [
		"cnss-daemon",
		"hostapd",
		"hostapd_cli",
		"wcnss_service",
		"wpa_cli",
		"wpa_supplicant",
	]
	libraries = [
		"libwifi-hal-qcom",
	]

class WifiConfigsSection(Section):
	name = "Wi-Fi configs"
	folders = [
		"etc/wifi",
	]

class WifiFirmwareSection(Section):
	name = "Wi-Fi firmware"
	folders = [
		"firmware/wigig",
		"firmware/wlan",
	]

register_section(WifiSection)
register_section(WifiConfigsSection)
register_section(WifiFirmwareSection)
