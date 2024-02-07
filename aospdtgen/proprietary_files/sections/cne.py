#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class CneSection(Section):
	name = "CNE"
	interfaces = [
		"com.quicinc.cne.api",
		"com.quicinc.cne.constants",
		"com.quicinc.cne.server",
		"vendor.qti.data.factory",
		"vendor.qti.data.mwqem",
		"vendor.qti.data.slm",
		"vendor.qti.hardware.cacert",
		"vendor.qti.hardware.data.cne.internal.api",
		"vendor.qti.hardware.data.cne.internal.constants",
		"vendor.qti.hardware.data.cne.internal.server",
		"vendor.qti.hardware.data.connection",
		"vendor.qti.hardware.data.connectionaidl",
		"vendor.qti.hardware.data.connectionfactory",
		"vendor.qti.hardware.data.dataactivity",
		"vendor.qti.hardware.data.dynamicdds",
		"vendor.qti.hardware.data.flow",
		"vendor.qti.hardware.data.iwlan",
		"vendor.qti.hardware.data.iwlandata",
		"vendor.qti.hardware.data.ka",
		"vendor.qti.hardware.data.latency",
		"vendor.qti.hardware.data.lce",
		"vendor.qti.hardware.data.qmi",
		"vendor.qti.hardware.factory",
		"vendor.qti.hardware.mwqemadapter",
		"vendor.qti.hardware.slmadapter",
		"vendor.qti.latency",
	]
	apps = [
		"CneApp",
	]
	binaries = [
		"cnd",
	]
	folders = [
		"etc/cne",
	]

register_section(CneSection)
