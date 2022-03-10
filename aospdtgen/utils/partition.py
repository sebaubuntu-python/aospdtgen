#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.lib.libprop import BuildProp
from aospdtgen.proprietary_files.ignore import is_blob_allowed
from pathlib import Path

(
	SYSTEM,
	PRODUCT,
	SYSTEM_EXT,
	VENDOR,
	ODM,
	ODM_DLKM,
	VENDOR_DLKM,
) = range(7)

PARTITION_STRING = {
	SYSTEM: "system",
	PRODUCT: "product",
	SYSTEM_EXT: "system_ext",
	VENDOR: "vendor",
	ODM: "odm",
	ODM_DLKM: "odm_dlkm",
	VENDOR_DLKM: "vendor_dlkm",
}

PROPRIETARY_FILES_PARTITION_PREFIX = {
	partition: Path(prefix) for partition, prefix in {
		SYSTEM: "",
		PRODUCT: "product",
		SYSTEM_EXT: "system_ext",
		VENDOR: "vendor",
		ODM: "odm",
		ODM_DLKM: "odm_dlkm",
		VENDOR_DLKM: "vendor_dlkm",
	}.items()
}

(
	SSI,
	TREBLE,
) = range(2)

SSI_PARTITIONS = [
	SYSTEM,
	PRODUCT,
	SYSTEM_EXT,
]

TREBLE_PARTITIONS = [
	VENDOR,
	ODM,
	ODM_DLKM,
	VENDOR_DLKM,
]

BUILD_PROP_LOCATION = ["default.prop", "etc/default.prop", "build.prop", "etc/build.prop"]

def get_dir(path: Path):
	dir = {}
	for i in path.iterdir():
		dir[i.name] = i if i.is_file() else get_dir(i)
	return dir

class AndroidPartition:
	def __init__(self, partition: int, real_path: Path, dump_path: Path):
		self.partition = partition
		self.real_path = real_path
		self.dump_path = dump_path

		self.name = PARTITION_STRING[partition]
		self.files: list[Path] = []
		self.proprietary_files_prefix = PROPRIETARY_FILES_PARTITION_PREFIX[self.partition]
		self.group = SSI if self.partition in SSI_PARTITIONS else TREBLE

		self.build_prop = BuildProp()
		for possible_paths in BUILD_PROP_LOCATION:
			build_prop_path = self.real_path / possible_paths
			if not build_prop_path.is_file():
				continue

			self.build_prop.import_props(build_prop_path)

	def get_relative_path(self):
		return self.real_path.relative_to(self.dump_path)

	def fill_files(self, files: list[Path]):
		for file in files:
			if not file.is_relative_to(self.real_path):
				continue

			if not is_blob_allowed(file.relative_to(self.real_path)):
				continue

			self.files.append(file)

	def get_formatted_file(self, file: Path):
		return self.proprietary_files_prefix / file.relative_to(self.real_path)

	def get_formatted_files(self):
		return [self.get_formatted_file(file) for file in self.files]
