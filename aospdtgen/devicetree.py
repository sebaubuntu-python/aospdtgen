#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.lib.libprop import BuildProp
from aospdtgen.proprietary_files.proprietary_files_list import ProprietaryFilesList
from aospdtgen.templates import render_template
from aospdtgen.utils.boot_configuration import BootConfiguration
from aospdtgen.utils.device_info import DeviceInfo
from aospdtgen.utils.fstab import Fstab
from aospdtgen.utils.ignored_props import IGNORED_PROPS
from aospdtgen.utils.reorder import reorder_key
from aospdtgen.utils.partition import BUILD_PROP_LOCATION, AndroidPartition, PartitionModel
from datetime import datetime
from pathlib import Path
from shutil import rmtree

class DeviceTree:
	def __init__(self, path: Path):
		self.path = path

		self.current_year = str(datetime.now().year)

		# All files
		self.all_files_txt = self.path / "all_files.txt"
		self.all_files = [file for file in self.all_files_txt.open().read().splitlines()
		                  if (self.path / file).is_file()]
		self.all_files = list(dict.fromkeys(self.all_files))
		self.all_files.sort(key=reorder_key)
		self.all_files = [self.path / file for file in self.all_files]

		# Determine partitions
		self.system = None
		self.product = None
		self.system_ext = None
		self.vendor = None
		self.odm = None

		# Find system
		for system in [self.path / "system", self.path / "system/system"]:
			for build_prop_location in BUILD_PROP_LOCATION:
				if system / build_prop_location not in self.all_files:
					continue

				self.system = AndroidPartition(PartitionModel.SYSTEM, system, self.path)

		if self.system is None:
			raise FileNotFoundError("System not found")

		# Find vendor
		for vendor in [self.system.real_path / "vendor", self.path / "vendor"]:
			for build_prop_location in BUILD_PROP_LOCATION:
				if vendor / build_prop_location not in self.all_files:
					continue

				self.vendor = AndroidPartition(PartitionModel.VENDOR, vendor, self.path)

		if self.vendor is None:
			raise FileNotFoundError("Vendor not found")

		# Find all the other partitions
		self.product = self.search_for_partition(PartitionModel.PRODUCT)
		self.system_ext = self.search_for_partition(PartitionModel.SYSTEM_EXT)
		self.odm = self.search_for_partition(PartitionModel.ODM)
		self.odm_dlkm = self.search_for_partition(PartitionModel.ODM_DLKM)
		self.vendor_dlkm = self.search_for_partition(PartitionModel.VENDOR_DLKM)

		self.partitions: list[AndroidPartition] = [
			partition for partition in [
				self.system,
				self.product,
				self.system_ext,
				self.vendor,
				self.odm,
				self.odm_dlkm,
				self.vendor_dlkm,
			] if partition is not None
		]

		# Associate files with partitions
		for partition in self.partitions:
			partition.fill_files(self.all_files)

		# Parse build prop and device info
		self.build_prop = BuildProp()
		for partition in self.partitions:
			self.build_prop.import_props(partition.build_prop)
		self.device_info = DeviceInfo(self.build_prop)

		# Parse fstab
		fstab = None
		for file in [file for file in self.vendor.files if file.relative_to(self.vendor.real_path).is_relative_to("etc") and file.name.startswith("fstab.")]:
			if file.is_file():
				fstab = file
				break
		self.fstab = Fstab(fstab)

		# Let the partitions know their fstab entries if any
		for partition in self.partitions:
			partition.fill_fstab_entry(self.fstab)

		# Get a list of A/B partitions
		self.ab_partitions: list[PartitionModel] = []
		if self.device_info.device_is_ab:
			for fstab_entry in self.fstab.get_slotselect_partitions():
				partition_model = PartitionModel.from_mount_point(fstab_entry.mount_point)
				if partition_model is None:
					continue

				self.ab_partitions.append(partition_model)

		# Get list of rootdir files
		self.rootdir_bin_files = [file for file in self.vendor.files if file.relative_to(self.vendor.real_path).is_relative_to("bin") and file.suffix == ".sh"]
		self.rootdir_etc_files = [file for file in self.vendor.files if file.relative_to(self.vendor.real_path).is_relative_to("etc/init/hw")]

		# Generate proprietary files list
		self.proprietary_files_list = ProprietaryFilesList(self.partitions, self.device_info.build_description)

		# Extract boot image
		self.boot_configuration = BootConfiguration(self.path / "boot.img",
		                                            self.path / "dtbo.img",
		                                            self.path / "vendor_boot.img")

	def search_for_partition(self, partition: PartitionModel):
		result = None
		possible_locations = [self.system.real_path / partition.name,
							  self.vendor.real_path / partition.name,
							  self.path / partition.name]

		for location in possible_locations:
			for build_prop_location in BUILD_PROP_LOCATION:
				if location / build_prop_location not in self.all_files:
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
		(folder / "proprietary-files.txt").write_text(str(self.proprietary_files_list))
		self.render_template(folder, "README.md")
		self.render_template(folder, "setup-makefiles.sh")

		# Dump build props
		for partition in self.partitions:
			if not partition.build_prop:
				continue

			(folder / f"{partition.model.name}.prop").write_text(partition.build_prop.get_readable_list(IGNORED_PROPS))

		# Dump boot image prebuilt files
		prebuilts_path = folder / "prebuilts"
		prebuilts_path.mkdir()

		self.boot_configuration.copy_files_to_folder(prebuilts_path)

		# Dump rootdir
		rootdir_path = folder / "rootdir"
		rootdir_path.mkdir()

		self.render_template(rootdir_path, "rootdir_Android.bp", "Android.bp", comment_prefix="//")

		# rootdir/bin
		rootdir_bin_path = rootdir_path / "bin"
		rootdir_bin_path.mkdir()

		for file in self.rootdir_bin_files:
			(rootdir_bin_path / file.name).write_bytes((self.path / self.vendor.real_path / file).read_bytes())

		# rootdir/etc
		rootdir_etc_path = rootdir_path / "etc"
		rootdir_etc_path.mkdir()

		for file in self.rootdir_etc_files:
			(rootdir_etc_path / file.name).write_bytes((self.path / self.vendor.real_path / file).read_bytes())

		(rootdir_etc_path / self.fstab.fstab.name).write_bytes(self.fstab.fstab.read_bytes())

	def render_template(self, *args, comment_prefix: str = "#", **kwargs):
		return render_template(*args,
		                       ab_partitions=self.ab_partitions,
		                       boot_configuration=self.boot_configuration,
		                       comment_prefix=comment_prefix,
		                       current_year=self.current_year,
		                       device_info=self.device_info,
		                       fstab=self.fstab,
		                       rootdir_bin_files=self.rootdir_bin_files,
		                       rootdir_etc_files=self.rootdir_etc_files,
		                       partitions=self.partitions,
		                       **kwargs)
