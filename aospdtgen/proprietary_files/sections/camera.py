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
		"motorola.hardware.camera.imgtuner",
		"vendor.mediatek.hardware.camera.atms",
		"vendor.mediatek.hardware.camera.bgservice",
		"vendor.mediatek.hardware.camera.frhandler",
		"vendor.mediatek.hardware.camera.isphal",
		"vendor.mediatek.hardware.camera.lomoeffect",
		"vendor.mediatek.hardware.camera.postproc",
		"vendor.mediatek.hardware.camera.security",
		"vendor.oplus.hardware.camera_rfi",
		"vendor.oplus.hardware.cammidasservice",
		"vendor.oplus.hardware.extcamera",
		"vendor.oplus.hardware.virtual_device.camera.hal",
		"vendor.oplus.hardware.virtual_device.camera.manager",
		"vendor.oplus.hardware.virtual_device.camera.provider",
		"vendor.qti.camera.provider",	
		"vendor.qti.hardware.camera.device",
		"vendor.qti.hardware.camera.offlinecamera",
		"vendor.qti.hardware.camera.postproc",
		"vendor.qti.hardware.scve.objecttracker",
		"vendor.qti.hardware.scve.panorama",
		"vendor.qti.hardware.seccam",
	]
	hardware_modules = [
		"camera",
		"com.qti.chi",
	]
	binaries = [
		"mm-qcamera-daemon",
		"virtualcameraprovider",
	]
	libraries = [
		"libscveBlobDescriptor_stub",
		"libscveCommon",
		"libscveCommon_stub",
		"libscveObjectSegmentation",
		"libscveObjectSegmentation_stub",
		"libscveObjectTracker",
		"libscveObjectTracker_stub",
		"libscvePanorama",
		"libscvePanorama_lite",
		"libscvePanorama_stub",
	]
	folders = [
		"lib/camera",
		"lib64/camera",
	]
	patterns = [
		"lib(64)?/com.qti.feature2\..*\.so",
		"lib(64)?/libCamera_.*\.so",
		"lib(64)?/libactuator_.*\.so",
		"lib(64)?/libarcsoft_.*\.so",
		"lib(64)?/libcamx.*\.so",
		"lib(64)?/libchromatix_.*\.so",
		"lib(64)?/libmmcamera_.*\.so",
		"lib(64)?/libmmcamera2_.*\.so",
		"lib(64)?/libois_.*\.so",
	]

class CameraConfigsSection(Section):
	name = "Camera configs"
	folders = [
		"camera",
		"etc/camera",
	]

class CameraFirmwareSection(Section):
	name = "Camera firmware"
	patterns = [
		"(.*/)?firmware/CAMERA_ICP.*",
	]

class CameraMotorSection(Section):
	name = "Camera motor"
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
register_section(CameraFirmwareSection)
register_section(CameraMotorSection)
