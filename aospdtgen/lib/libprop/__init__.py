#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from __future__ import annotations
from distutils.util import strtobool
from pathlib import Path
from typing import Union

PARTITIONS = [
	"bootimage",
	"odm",
	"odm_dlkm",
	"product",
	"system",
	"system_ext",
	"vendor",
	"vendor_dlkm",
]

def get_partition_props(format_string: str, add_empty: bool = False):
	"""
	Get a list of props given a string to format.

	If add_empty is True, you need to omit a dot at the end of the partition
	(e.g. "ro.{}.build.date" if add_empty is False, "ro.{}build.date" otherwise).
	"""
	partitions_formatted = [
		(f"{part}." if add_empty else part) for part in PARTITIONS
	]

	partition_props = [format_string.format(partition) for partition in partitions_formatted]
	if add_empty:
		partition_props.append(format_string.format(""))

	return partition_props

class BuildProp(dict):
	"""
	A class representing a build prop.
	This class basically mimics Android props system, with both getprop and setprop commands
	"""
	def __init__(self, *args, file: Path = None, **kwargs):
		"""
		Create a dictionary containing all the key-value from a build prop.
		"""
		super().__init__(*args, **kwargs)

		if not file:
			return

		self.import_props(file)

	def __str__(self):
		return self.get_readable_list()

	def get_readable_list(self, excluded_props: list[str] = []):
		ordered_props = dict(sorted(self.items()))

		for excluded_prop in excluded_props:
			ordered_props.pop(excluded_prop, None)

		return "\n".join(f"{key}={value}" for key, value in ordered_props.items()) + "\n"

	def import_props(self, file: Union[Path, BuildProp]):
		if isinstance(file, BuildProp):
			text = str(file)
		else:
			text = file.read_text(encoding="utf-8")

		for prop in text.splitlines():
			if prop.startswith("#"):
				continue
			try:
				prop_name, prop_value = prop.split("=", 1)
			except ValueError:
				continue
			else:
				self.set_prop(prop_name, prop_value)

	def get_prop(self, key: str, default: str = None):
		if key in self:
			return self[key]
		else:
			return default

	def get_prop_bool(self, key: str, default: bool = False):
		value = self.get_prop(key)

		try:
			return strtobool(value)
		except ValueError:
			return default

	def get_prop_int(self, key: str, default: int = 0):
		value = self.get_prop(key)

		try:
			return int(value)
		except ValueError:
			return default

	def get_prop_float(self, key: str, default: float = 0.0):
		value = self.get_prop(key)

		try:
			return float(value)
		except ValueError:
			return default

	def set_prop(self, key: str, value: str):
		self[key] = value
