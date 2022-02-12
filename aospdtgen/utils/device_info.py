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
DEVICE_ARCH = [f"ro.{partition}product.cpu.abi" for partition in PARTITIONS] + [f"ro.{partition}product.cpu.abilist" for partition in PARTITIONS]
DEVICE_IS_AB = ["ro.build.ab_update"]
DEVICE_PLATFORM = ["ro.board.platform"]
DEVICE_PIXEL_FORMAT = ["ro.minui.pixel_format"]
BUILD_FINGERPRINT = [f"ro.{partition}build.fingerprint" for partition in PARTITIONS]
BUILD_DESCRIPTION = [f"ro.{partition}build.description" for partition in PARTITIONS]
GMS_CLIENTID_BASE = ["ro.com.google.clientidbase.ms", "ro.com.google.clientidbase"]
FIRST_ARCH_CPU_VARIANT = ["ro.bionic.cpu_variant"]
SECOND_ARCH_CPU_VARIANT = ["ro.bionic.2nd_cpu_variant"]

class _DeviceArch:
	def __init__(self, arch: int, string: str, kernel_name: str):
		self.arch = arch
		self.string = string
		self.kernel_name = kernel_name

	def __str__(self):
		return self.string

class DeviceArch(_DeviceArch):
	(
		_ARM,
		_ARM64,
		_X86,
		_X86_64,
		_MIPS,
		_UNKNOWN,
	) = range(6)

	ARM = _DeviceArch(_ARM, "arm", "zImage")
	ARM64 = _DeviceArch(_ARM64, "arm64", "Image.gz")
	X86 = _DeviceArch(_X86, "x86", "bzImage")
	X86_64 = _DeviceArch(_X86_64, "x86_64", "bzImage")
	MIPS = _DeviceArch(_MIPS, "mips", "Image")
	UNKNOWN = _DeviceArch(_UNKNOWN, "unknown", "Image")

	@classmethod
	def from_arch_string(cls, arch: str):
		if arch.startswith("arm64"):
			return cls.ARM64
		if arch.startswith("armeabi"):
			return cls.ARM
		if arch.startswith("x86"):
			return cls.X86
		if arch.startswith("x86_64"):
			return cls.X86_64
		if arch.startswith("mips"):
			return cls.MIPS

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
		self.first_arch_cpu_variant = self.get_prop(FIRST_ARCH_CPU_VARIANT, default="generic")
		self.second_arch_cpu_variant = self.get_prop(SECOND_ARCH_CPU_VARIANT, default="generic")
		self.device_has_64bit_arch = self.arch in (DeviceArch.ARM64, DeviceArch.X86_64)
		self.platform = self.get_prop(DEVICE_PLATFORM, default="default")
		self.device_is_ab = bool(strtobool(self.get_prop(DEVICE_IS_AB, default="false")))
		self.device_pixel_format = self.get_prop(DEVICE_PIXEL_FORMAT, raise_exception=False)
		self.gms_clientid_base = self.get_prop(GMS_CLIENTID_BASE, default=f"android-{self.manufacturer}")

	def get_prop(self, props: list, default: str = None, raise_exception: bool = True):
		for prop in props:
			prop_value = self.buildprop.get_prop(prop)
			if prop_value is not None:
				return prop_value

		if default is None and raise_exception:
			raise AssertionError(f'Property {props[0]} could not be found in build.prop')
		else:
			return default
