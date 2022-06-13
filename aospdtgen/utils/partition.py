#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from __future__ import annotations
from pathlib import Path
from sebaubuntu_libs.libfstab import Fstab, FstabEntry
from sebaubuntu_libs.libprop import BuildProp
from sebaubuntu_libs.libreorder import strcoll_files_key
from sebaubuntu_libs.libvintf.manifest import Manifest

(
	BOOTLOADER,
	SSI,
	TREBLE,
	DATA,
) = range(4)

class _PartitionModel:
	ALL: list[_PartitionModel] = []

	def __init__(self,
	             name: str,
	             group: int,
				 mount_points: list[str] = None,
				 proprietary_files_prefix: Path = None,
	            ):
		self.name = name
		self.group = group
		self.mount_points = mount_points
		self.proprietary_files_prefix = proprietary_files_prefix

		if self.mount_points is None:
			self.mount_points = [f"/{self.name}"]

		if self.proprietary_files_prefix is None:
			self.proprietary_files_prefix = Path(self.name)

		_PartitionModel.ALL.append(self)

	@classmethod
	def from_name(cls, name: str):
		for model in cls.ALL:
			if model.name == name:
				return model

		return None

	@classmethod
	def from_group(cls, group: int):
		return [model for model in cls.ALL if model.group == group]

	@classmethod
	def from_mount_point(cls, mount_point: str):
		for model in cls.ALL:
			if mount_point in model.mount_points:
				return model

		return None

class PartitionModel(_PartitionModel):
	BOOT = _PartitionModel("boot", BOOTLOADER)
	DTBO = _PartitionModel("dtbo", BOOTLOADER)
	RECOVERY = _PartitionModel("recovery", BOOTLOADER)
	MISC = _PartitionModel("misc", BOOTLOADER)
	VBMETA = _PartitionModel("vbmeta", BOOTLOADER)
	VBMETA_SYSTEM = _PartitionModel("vbmeta_system", BOOTLOADER)
	VBMETA_VENDOR = _PartitionModel("vbmeta_vendor", BOOTLOADER)

	SYSTEM = _PartitionModel("system", SSI, ["/system", "/"], Path(""))
	PRODUCT = _PartitionModel("product", SSI)
	SYSTEM_EXT = _PartitionModel("system_ext", SSI)

	VENDOR = _PartitionModel("vendor", TREBLE)
	ODM = _PartitionModel("odm", TREBLE)
	ODM_DLKM = _PartitionModel("odm_dlkm", TREBLE)
	VENDOR_DLKM = _PartitionModel("vendor_dlkm", TREBLE)

	USERDATA = _PartitionModel("data", DATA)
	CACHE = _PartitionModel("cache", DATA)
	METADATA = _PartitionModel("metadata", DATA)

BUILD_PROP_LOCATION = ["build.prop", "etc/build.prop"]
DEFAULT_PROP_LOCATION = ["default.prop", "etc/default.prop"]

def get_dir(path: Path):
	dir = {}
	for i in path.iterdir():
		dir[i.name] = i if i.is_file() else get_dir(i)
	return dir

class AndroidPartition:
	def __init__(self, model: PartitionModel, real_path: Path, dump_path: Path):
		self.model = model
		self.real_path = real_path
		self.dump_path = dump_path

		self.files: list[Path] = []
		self.fstab_entry: FstabEntry = None

		self.build_prop = BuildProp()
		for possible_paths in BUILD_PROP_LOCATION + DEFAULT_PROP_LOCATION:
			build_prop_path = self.real_path / possible_paths
			if not build_prop_path.is_file():
				continue

			self.build_prop.import_props(build_prop_path)

		self.manifest = Manifest()
		for possible_paths in ["etc/vintf/manifest.xml", "manifest.xml"]:
			manifest_path = self.real_path / possible_paths
			if not manifest_path.is_file():
				continue

			self.manifest.import_file(manifest_path)

	def get_relative_path(self):
		return self.real_path.relative_to(self.dump_path)

	def fill_files(self, files: list[Path]):
		for file in files:
			if not file.is_relative_to(self.real_path):
				continue

			self.files.append(file)

	def fill_fstab_entry(self, fstab: Fstab):
		for mount_point in self.model.mount_points:
			self.fstab_entry = fstab.get_partition_by_mount_point(mount_point)
			if self.fstab_entry is not None:
				return

	def get_files(self):
		"""Returns the ordered list of files."""
		self.files.sort(key=strcoll_files_key)
		return self.files

	def get_formatted_file(self, file: Path):
		return self.model.proprietary_files_prefix / file.relative_to(self.real_path)

	def get_formatted_files(self):
		return [self.get_formatted_file(file) for file in self.get_files()]
