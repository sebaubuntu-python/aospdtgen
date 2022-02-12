#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.lib.libprop import BuildProp
from aospdtgen.proprietary_files.proprietary_files_list import ProprietaryFilesList
from aospdtgen.templates import render_template
from aospdtgen.utils.device_info import DeviceInfo
from aospdtgen.utils.reorder import reorder_key
from aospdtgen.utils.partition import BUILD_PROP_LOCATION, AndroidPartition, PARTITION_STRING
from aospdtgen.utils.partition import ODM, PRODUCT, SYSTEM, SYSTEM_EXT, VENDOR
from datetime import datetime
from pathlib import Path
from shutil import rmtree

class DeviceTree:
	def __init__(self, path: Path):
		self.path = path

		self.current_year = str(datetime.now().year)

		self.all_files_txt = self.path / "all_files.txt"
		self.all_files = [file for file in self.all_files_txt.open().read().splitlines()
		                  if (self.path / file).is_file()]
		self.all_files = list(dict.fromkeys(self.all_files))
		self.all_files.sort(key=reorder_key)

		# Determine partitions
		self.system = None
		self.product = None
		self.system_ext = None
		self.vendor = None
		self.odm = None

		for system in ["system", "system/system"]:
			for build_prop_location in BUILD_PROP_LOCATION:
				if not (f"{system}/{build_prop_location}" in self.all_files):
					continue

				self.system = AndroidPartition(SYSTEM, system, self.path)

		if self.system is None:
			raise FileNotFoundError("System not found")

		for vendor in [f"{self.system.real_path}/vendor", "vendor"]:
			for build_prop_location in BUILD_PROP_LOCATION:
				if not (f"{vendor}/{build_prop_location}" in self.all_files):
					continue

				self.vendor = AndroidPartition(VENDOR, vendor, self.path)

		if self.vendor is None:
			raise FileNotFoundError("Vendor not found")

		self.product = self.search_for_partition(PRODUCT)
		self.system_ext = self.search_for_partition(SYSTEM_EXT)
		self.odm = self.search_for_partition(ODM)

		self.partitions: list[AndroidPartition] = [
			partition for partition in [
				self.system,
				self.product,
				self.system_ext,
				self.vendor,
				self.odm,
			] if partition is not None
		]

		for partition in self.partitions:
			partition.fill_files(self.all_files)

		self.build_prop = BuildProp()
		for partition in self.partitions:
			self.build_prop.import_props(partition.build_prop)
		self.device_info = DeviceInfo(self.build_prop)

		self.proprietary_files_list = ProprietaryFilesList(self.partitions, self.device_info.build_description)

	def search_for_partition(self, partition: int):
		result = None
		possible_locations = [f"{self.system}/{PARTITION_STRING[partition]}",
							  f"{self.vendor}/{PARTITION_STRING[partition]}",
							  PARTITION_STRING[partition]]

		for location in possible_locations:
			for build_prop_location in BUILD_PROP_LOCATION:
				if not (f"{location}/{build_prop_location}" in self.all_files):
					continue

				result = AndroidPartition(partition, location, self.path)

		return result

	def search_file_in_partitions(self, file: str):
		files = []

		for file in [f"{partition.real_path}/{file}" for partition in self.partitions]:
			if not (file in self.all_files):
				continue

			files.append(file)

		return files

	def dump_to_folder(self, folder: Path):
		if folder.is_dir():
			rmtree(folder)
		folder.mkdir(parents=True)

		self.render_template(folder, "Android.bp", comment_prefix="//")
		self.render_template(folder, "Android.mk")
		self.render_template(folder, "AndroidProducts.mk")
		self.render_template(folder, "BoardConfig.mk")
		self.render_template(folder, "device.mk")
		self.render_template(folder, "extract-files.sh")
		self.render_template(folder, "lineage_device.mk", out_file=f"lineage_{self.device_info.codename}.mk")
		self.write_proprietary_files(folder / "proprietary-files.txt")
		self.render_template(folder, "README.md")
		self.render_template(folder, "setup-makefiles.sh")

		for partition in self.partitions:
			if not partition.build_prop:
				continue

			(folder / f"{partition.name}.prop").write_text(str(partition.build_prop))

	def render_template(self, *args, comment_prefix: str = "#", **kwargs):
		return render_template(*args,
		                       comment_prefix=comment_prefix,
		                       current_year=self.current_year,
		                       device_info=self.device_info,
		                       partitions=self.partitions,
		                       **kwargs)

	def write_proprietary_files(self, file: Path):
		with file.open("w") as f:
			f.write(str(self.proprietary_files_list))
