#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.lib.libprop import BuildProp
from distutils.util import strtobool

PARTITIONS = [
	"",
	"bootimage.",
	"odm.",
	"odm_dlkm.",
	"product.",
	"system.",
	"system_ext.",
	"vendor.",
	"vendor_dlkm.",
]

def get_product_props(value: str):
	return [f"ro.product.{partition}{value}" for partition in PARTITIONS]

DEVICE_CODENAME = get_product_props("device")
DEVICE_MANUFACTURER = get_product_props("manufacturer")
DEVICE_BRAND = get_product_props("brand")
DEVICE_MODEL = get_product_props("model")

DEVICE_ARCH = ["ro.bionic.arch"]
DEVICE_CPU_VARIANT = ["ro.bionic.cpu_variant"]
DEVICE_SECOND_ARCH = ["ro.bionic.2nd_arch"]
DEVICE_SECOND_CPU_VARIANT = ["ro.bionic.2nd_cpu_variant"]

DEVICE_IS_AB = ["ro.build.ab_update"]
DEVICE_USES_DYNAMIC_PARTITIONS = ["ro.boot.dynamic_partitions"]
DEVICE_PLATFORM = ["ro.board.platform"]
DEVICE_PIXEL_FORMAT = ["ro.minui.pixel_format"]
SCREEN_DENSITY = ["ro.sf.lcd_density"]
BUILD_FINGERPRINT = [f"ro.{partition}build.fingerprint" for partition in PARTITIONS]
BUILD_DESCRIPTION = [f"ro.{partition}build.description" for partition in PARTITIONS]
GMS_CLIENTID_BASE = ["ro.com.google.clientidbase.ms", "ro.com.google.clientidbase"]
BUILD_SECURITY_PATCH = ["ro.build.version.security_patch"]
BUILD_VENDOR_SECURITY_PATCH = ["ro.vendor.build.security_patch"]

class _DeviceArch:
	def __init__(self,
	             arch: str,
	             arch_variant: str,
	             cpu_abi: str,
	             cpu_abi2: str = "",
	             kernel_name: str = "Image"):
		self.arch = arch
		self.arch_variant = arch_variant
		self.cpu_abi = cpu_abi
		self.cpu_abi2 = cpu_abi2
		self.kernel_name = kernel_name

	def __bool__(self):
		return self.arch != "unknown"

	def __str__(self):
		return self.arch

class DeviceArch(_DeviceArch):
	ARM = _DeviceArch("arm", "armv7-a-neon", "armeabi-v7a", "armeabi", "zImage")
	ARM64 = _DeviceArch("arm64", "armv8-a", "arm64-v8a", "", "Image.gz")
	X86 = _DeviceArch("x86", "generic", "x86", "", "bzImage")
	X86_64 = _DeviceArch("x86_64", "generic", "x86_64", "", "bzImage")
	UNKNOWN = _DeviceArch("unknown", "generic", "unknown")

	@classmethod
	def from_arch_string(cls, arch: str):
		if not arch:
			return None

		if arch == "arm64":
			return cls.ARM64
		if arch == "arm":
			return cls.ARM
		if arch == "x86":
			return cls.X86
		if arch == "x86_64":
			return cls.X86_64

		return cls.UNKNOWN

def fingerprint_to_description(fingerprint: str):
	_, temp = fingerprint.split("/", 1) # brand
	product, temp = temp.split("/", 1)
	_, temp = temp.split(":", 1) # device
	platform_version, temp = temp.split("/", 1)
	build_id, temp = temp.split("/", 1)
	build_number, temp = temp.split(":", 1)
	build_variant, build_version_tags = temp.split("/", 1)

	return f"{product}-{build_variant} {platform_version} {build_id} {build_number} {build_version_tags}"

class DeviceInfo:
	"""
	This class is responsible for reading parse common build props needed for twrpdtgen
	by using BuildProp class.
	"""

	def __init__(self, buildprop: BuildProp):
		"""
		Parse common build props.
		"""
		self.buildprop = buildprop

		# Parse props
		self.codename = self.get_prop(DEVICE_CODENAME)
		self.manufacturer = self.get_prop(DEVICE_MANUFACTURER).split()[0].lower()
		self.brand = self.get_prop(DEVICE_BRAND)
		self.model = self.get_prop(DEVICE_MODEL)
		self.build_fingerprint = self.get_prop(BUILD_FINGERPRINT)
		self.build_description = self.get_prop(BUILD_DESCRIPTION, default=fingerprint_to_description(self.build_fingerprint))

		self.arch = DeviceArch.from_arch_string(self.get_prop(DEVICE_ARCH))
		self.second_arch = DeviceArch.from_arch_string(self.get_prop(DEVICE_SECOND_ARCH))
		self.cpu_variant = self.get_prop(DEVICE_CPU_VARIANT, default="generic")
		self.second_cpu_variant = self.get_prop(DEVICE_SECOND_CPU_VARIANT, default="generic")
		self.device_has_64bit_arch = self.arch in (DeviceArch.ARM64, DeviceArch.X86_64)
		# TODO: Add 32binder64 detection (it only involves 8.0/8.1 devices so :shrug:)
		self.device_has_64bit_binder = True

		self.platform = self.get_prop(DEVICE_PLATFORM, default="default")
		self.device_is_ab = bool(strtobool(self.get_prop(DEVICE_IS_AB, default="false")))
		self.device_uses_dynamic_partitions = bool(strtobool(self.get_prop(DEVICE_USES_DYNAMIC_PARTITIONS, default="false")))
		self.device_pixel_format = self.get_prop(DEVICE_PIXEL_FORMAT, raise_exception=False)
		self.screen_density = self.get_prop(SCREEN_DENSITY, raise_exception=False)
		self.gms_clientid_base = self.get_prop(GMS_CLIENTID_BASE, default=f"android-{self.manufacturer}")

		self.build_security_patch = self.get_prop(BUILD_SECURITY_PATCH)
		self.vendor_build_security_patch = self.get_prop(BUILD_VENDOR_SECURITY_PATCH, default=self.build_security_patch)

	def get_prop(self, props: list, default: str = None, raise_exception: bool = True):
		for prop in props:
			prop_value = self.buildprop.get_prop(prop)
			if prop_value is not None:
				return prop_value

		if default is None and raise_exception:
			raise AssertionError(f'Property {props[0]} could not be found in build.prop')
		else:
			return default
