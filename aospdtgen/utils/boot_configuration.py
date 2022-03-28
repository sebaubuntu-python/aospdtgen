#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.lib.libaik import AIKManager
from pathlib import Path

class BootConfiguration:
	def __init__(self,
	             boot: Path,
	             dtbo: Path = None,
	             recovery: Path = None,
	             vendor_boot: Path = None,
	            ):
		self.boot = boot
		self.dtbo = dtbo
		self.recovery = recovery
		self.vendor_boot = vendor_boot

		self.boot_aik_manager = AIKManager()
		self.boot_image_info = self.boot_aik_manager.unpackimg(self.boot)

		if self.recovery and self.recovery.is_file():
			self.recovery_aik_manager = AIKManager()
			self.recovery_image_info = self.recovery_aik_manager.unpackimg(self.recovery)
		else:
			self.recovery_aik_manager = None
			self.recovery_image_info = None

		if self.vendor_boot and self.vendor_boot.is_file():
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

	def copy_files_to_folder(self, folder: Path) -> None:
		if self.kernel:
			(folder / "kernel").write_bytes(self.kernel.read_bytes())

		if self.dt:
			(folder / "dt.img").write_bytes(self.dt.read_bytes())

		if self.dtb:
			(folder / "dtb.img").write_bytes(self.dtb.read_bytes())

		if self.dtbo:
			(folder / "dtbo.img").write_bytes(self.dtbo.read_bytes())

	def cleanup(self):
		self.boot_aik_manager.cleanup()

		if self.recovery_aik_manager:
			self.recovery_aik_manager.cleanup()

		if self.vendor_boot_aik_manager:
			self.vendor_boot_aik_manager.cleanup()
