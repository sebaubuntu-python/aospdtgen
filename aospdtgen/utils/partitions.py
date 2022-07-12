#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from pathlib import Path
from typing import Dict

from aospdtgen.utils.partition import SSI, TREBLE, AndroidPartition, PartitionModel, BUILD_PROP_LOCATION

class Partitions:
	def __init__(self, dump_path: Path):
		self.dump_path = dump_path

		self.partitions: Dict[PartitionModel, AndroidPartition] = {}

		# Search for system
		for system in [self.dump_path / "system", self.dump_path / "system/system"]:
			for build_prop_location in BUILD_PROP_LOCATION:
				if not (system / build_prop_location).is_file():
					continue

				self.partitions[PartitionModel.SYSTEM] = AndroidPartition(PartitionModel.SYSTEM, system, self.dump_path)

		assert PartitionModel.SYSTEM in self.partitions
		self.system = self.partitions[PartitionModel.SYSTEM]

		# Search for vendor
		for vendor in [self.partitions[PartitionModel.SYSTEM].real_path / "vendor", self.dump_path / "vendor"]:
			for build_prop_location in BUILD_PROP_LOCATION:
				if not (vendor / build_prop_location).is_file():
					continue

				self.partitions[PartitionModel.VENDOR] = AndroidPartition(PartitionModel.VENDOR, vendor, self.dump_path)

		assert PartitionModel.VENDOR in self.partitions
		self.vendor = self.partitions[PartitionModel.VENDOR]

		# Search for the other partitions
		for model in [model for model in PartitionModel.from_group(SSI) if not (model is PartitionModel.SYSTEM)]:
			self._search_for_partition(model)

		for model in [model for model in PartitionModel.from_group(TREBLE) if not (model is PartitionModel.VENDOR)]:
			self._search_for_partition(model)

	def get_partition(self, model: PartitionModel):
		if not model:
			return None

		if model in self.partitions:
			return self.partitions[model]

		return None

	def get_partition_by_name(self, name: str):
		return self.get_partition(PartitionModel.from_name(name))

	def get_all_partitions(self):
		return self.partitions.values()

	def _search_for_partition(self, model: PartitionModel):
		possible_locations = [
			self.partitions[PartitionModel.SYSTEM].real_path / model.name,
			self.partitions[PartitionModel.VENDOR].real_path / model.name,
			self.dump_path / model.name
		]

		for location in possible_locations:
			for build_prop_location in BUILD_PROP_LOCATION:
				if not (location / build_prop_location).is_file():
					continue

				self.partitions[model] = AndroidPartition(model, location, self.dump_path)
