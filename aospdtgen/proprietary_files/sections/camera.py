#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.section import Section, register_section

class CameraSection(Section):
	name = "Camera"
	interfaces = [
		"android.hardware.camera.common",
		"android.hardware.camera.device",
		"android.hardware.camera.metadata",
		"android.hardware.camera.provider",
		"camera.device",
		"vendor.qti.hardware.camera.device",
		"vendor.qti.hardware.camera.postproc",
		"vendor.qti.hardware.scve.objecttracker",
		"vendor.qti.hardware.scve.panorama",
		"vendor.qti.hardware.seccam",
	]
	hardware_modules = [
		"camera",
		"com.qti.chi",
	]
	folders = [
		"lib/camera",
		"lib64/camera",
	]
	patterns = [
		"lib(64)?/com.qti.feature2\..*\.so",
		"lib(64)?/libchromatix_.*\.so",
		"lib(64)?/libmmcamera_.*\.so",
	]

class CameraConfigsSection(Section):
	name = "Camera configs"
	folders = [
		"camera",
		"etc/camera",
	]

class CameraMotorSection(Section):
	name = "Camera (motor)"
	interfaces = [
		"vendor.xiaomi.hardware.motor",
	]
	libraries = [
		"mi.motor.daemon",
	]
	folders = [
		"etc/step_motor",
	]
	patterns = [
		"lib(64)?/libmivendor_module_.*\.so",
	]

register_section(CameraSection)
register_section(CameraConfigsSection)
register_section(CameraMotorSection)
