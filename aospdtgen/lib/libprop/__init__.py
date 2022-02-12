#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from __future__ import annotations
from ctypes import Union
from distutils.util import strtobool
from pathlib import Path

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

	def import_props(self, file: Union[Path, BuildProp]):
		if isinstance(file, BuildProp):
			text = str(file)
		else:
			text = file.read_text()

		for prop in text.splitlines():
			if prop.startswith("#"):
				continue
			try:
				prop_name, prop_value = prop.split("=", 1)
			except ValueError:
				continue
			else:
				self.set_prop(prop_name, prop_value)

	def __str__(self):
		return "\n".join(f"{key}={value}" for key, value in self.items()) + "\n"

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
