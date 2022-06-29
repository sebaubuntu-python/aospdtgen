#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from pathlib import Path
from sebaubuntu_libs.libaik import AIKManager
from typing import Union

class BootConfiguration:
	"""Class representing a device's boot configuration."""
	def __init__(self, dump_path: Path):
		"""
		Given the path to a dump, parse all the images
		and generate a boot configuration.
		"""
		self.dump_path = dump_path

		self.boot = self._get_image_path("boot")
		self.dtbo = self._get_image_path("dtbo")
		self.recovery = self._get_image_path("recovery")
		self.vendor_boot = self._get_image_path("vendor_boot")

		self.boot_aik_manager = AIKManager()
		self.boot_image_info = self.boot_aik_manager.unpackimg(self.boot)

		if self.recovery:
			self.recovery_aik_manager = AIKManager()
			self.recovery_image_info = self.recovery_aik_manager.unpackimg(self.recovery)
		else:
			self.recovery_aik_manager = None
			self.recovery_image_info = None

		if self.vendor_boot:
			self.vendor_boot_aik_manager = AIKManager()
			self.vendor_boot_image_info = self.vendor_boot_aik_manager.unpackimg(self.vendor_boot)
		else:
			self.vendor_boot_aik_manager = None
			self.vendor_boot_image_info = None

		self.kernel = None
		self.dt = None
		self.dtb = None

		self.cmdline = None
		self.pagesize = None

		if self.vendor_boot_image_info:
			self.kernel = self.vendor_boot_image_info.kernel
			self.dt = self.vendor_boot_image_info.dt
			self.dtb = self.vendor_boot_image_info.dtb
			self.dtbo = self.dtbo if self.dtbo else self.vendor_boot_image_info.dtbo

			self.cmdline = self.vendor_boot_image_info.cmdline
			self.pagesize = self.vendor_boot_image_info.pagesize

		self.kernel = self.kernel if self.kernel else self.boot_image_info.kernel
		self.dt = self.dt if self.dt else self.boot_image_info.dt
		self.dtb = self.dtb if self.dtb else self.boot_image_info.dtb
		self.dtbo = self.dtbo if self.dtbo else self.boot_image_info.dtbo

		self.cmdline = self.cmdline if self.cmdline else self.boot_image_info.cmdline
		self.pagesize = self.pagesize if self.pagesize else self.boot_image_info.pagesize

	def _get_image_path(self, partition: str) -> Union[Path, None]:
		path = self.dump_path / f"{partition}.img"
		return path if path.is_file() else None

	def copy_files_to_folder(self, folder: Path) -> None:
		"""Copy all prebuilts to a folder."""
		if self.kernel:
			(folder / "kernel").write_bytes(self.kernel.read_bytes())

		if self.dt:
			(folder / "dt.img").write_bytes(self.dt.read_bytes())

		if self.dtb:
			(folder / "dtb.img").write_bytes(self.dtb.read_bytes())

		if self.dtbo:
			(folder / "dtbo.img").write_bytes(self.dtbo.read_bytes())

	def cleanup(self):
		"""Cleanup all the temporary files. Do not use this object anymore after calling this."""
		self.boot_aik_manager.cleanup()

		if self.recovery_aik_manager:
			self.recovery_aik_manager.cleanup()

		if self.vendor_boot_aik_manager:
			self.vendor_boot_aik_manager.cleanup()
