#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class BluetoothSection(Section):
	name = "Bluetooth"
	interfaces = [
		"android.hardware.bluetooth",
	]
	hardware_modules = [
		"bluetooth",
	]

class BluetoothA2dpSection(Section):
	name = "Bluetooth (A2DP)"
	interfaces = [
		"android.hardware.bluetooth.a2dp",
		"android.hardware.bluetooth.audio",
		"com.qualcomm.qti.bluetooth_audio",
		"vendor.qti.hardware.bluetooth_audio",
		"vendor.qti.hardware.bluetooth_sar",
		"vendor.qti.hardware.btconfigstore",
	]
	hardware_modules = [
		"audio.bluetooth",
		"audio.bluetooth_qti",
	]

register_section(BluetoothSection)
register_section(BluetoothA2dpSection)
