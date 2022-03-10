#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from itertools import repeat
from pathlib import Path

FSTAB_HEADER = "#<src>                                                 <mnt_point>            <type>  <mnt_flags and options>                            <fs_mgr_flags>\n"

class FstabEntry:
	"""
	A class representing a fstab entry
	"""
	def __init__(self,
	             src: str,
	             mount_point: str,
	             fs_type: str,
	             mnt_flags: list[str],
	             fs_flags: list[str],
	            ) -> None:
		self.src = src
		self.mount_point = mount_point
		self.fs_type = fs_type
		self.mnt_flags = mnt_flags
		self.fs_flags = fs_flags

	def is_logical(self):
		return "logical" in self.fs_flags

	def is_slotselect(self):
		return "slotselect" in self.fs_flags

	@classmethod
	def from_entry(cls, line: str):
		src, mount_point, fs_type, mnt_flags, fs_flags = line.split()

		return cls(src, mount_point, fs_type, mnt_flags.split(','), fs_flags.split(','))

class Fstab:
	def __init__(self, fstab: Path):
		self.fstab = fstab

		self.entries: list[FstabEntry] = []

		for line in self.fstab.read_text().splitlines():
			if not line:
				continue

			if line.startswith("#"):
				continue

			self.entries.append(FstabEntry.from_entry(line))

	def __str__(self):
		string = FSTAB_HEADER

		src_len_max = 0
		mount_point_len_max = 0
		fs_type_len_max = 0
		mnt_flags_len_max = 0

		for entry in self.entries:
			mount_point_len = len(entry.mount_point)
			if mount_point_len > mount_point_len_max:
				mount_point_len_max = mount_point_len

			fs_type_len = len(entry.fs_type)
			if fs_type_len > fs_type_len_max:
				fs_type_len_max = fs_type_len

			src_len = len(entry.src)
			if src_len > src_len_max:
				src_len_max = src_len

			mnt_flags_len = len(entry.mnt_flags)
			if mnt_flags_len > mnt_flags_len_max:
				mnt_flags_len_max = mnt_flags_len

		src_len_max += 5
		mount_point_len_max += 5
		fs_type_len_max += 5
		mnt_flags_len_max += 5

		for entry in self.entries:
			src_space = ""
			mount_point_space = ""
			fstype_space = ""
			mnt_flags_space = ""

			for _ in repeat(None, src_len_max - len(entry.src)):
				src_space += " "
			for _ in repeat(None, mount_point_len_max - len(entry.mount_point)):
				mount_point_space += " "
			for _ in repeat(None, fs_type_len_max - len(entry.fs_type)):
				fstype_space += " "
			for _ in repeat(None, mnt_flags_len_max - len(entry.mnt_flags)):
				mnt_flags_space += " "
			string += f"{entry.src}{src_space}{entry.mount_point}{mount_point_space}{entry.fs_type}{fstype_space}{','.join(entry.mnt_flags)}{mnt_flags_space}{','.join(entry.fs_flags)}\n"

		return string

	def get_partition_by_mount_point(self, mount_point: str):
		for entry in self.entries:
			if entry.mount_point == mount_point:
				return entry

		return None

	def get_logical_partitions(self):
		return [entry for entry in self.entries if entry.is_logical()]

	def get_slotselect_partitions(self):
		return [entry for entry in self.entries if entry.is_slotselect()]
