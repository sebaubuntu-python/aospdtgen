#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.lib.liblogging import LOGI, LOGW
from aospdtgen.lib.libvintf import INDENTATION
from aospdtgen.lib.libvintf.aidl import AidlHal
from aospdtgen.lib.libvintf.common import Hal
from aospdtgen.lib.libvintf.hidl import HidlHal
from functools import cmp_to_key
from locale import strcoll
from pathlib import Path
from xml.etree import ElementTree
from textwrap import indent

def strcoll_hal(obj1: Hal, obj2: Hal) -> int:
	# Sort by name if different
	if obj1.name != obj2.name:
		return strcoll(obj1.name, obj2.name)

	# AIDL first
	if isinstance(obj1, AidlHal) and not isinstance(obj2, AidlHal):
		return -1
	if isinstance(obj2, AidlHal) and not isinstance(obj1, AidlHal):
		return 1

	# transport=hwbinder first if both HIDL
	if isinstance(obj1, HidlHal) and isinstance(obj2, HidlHal) and obj1.transport != obj2.transport:
		return 1 if obj1.transport == "hwbinder" else -1

	# Compare normally
	return strcoll(obj1.name, obj2.name)

class Manifest:
	"""A class representing a VINTF manifest."""
	def __init__(self):
		"""Parse a VINTF manifest."""
		self.version = None
		self.type: str = None
		self.target_level: str = None
		self.entries: list[Hal] = []

	def __str__(self):
		string = f'<manifest version="{self.version}" type="{self.type}" target-level="{self.target_level}">\n'
		for entry in sorted(self.entries, key=cmp_to_key(strcoll_hal)):
			string += indent(f"{entry}\n", INDENTATION)
		string += "</manifest>\n"

		return string

	def import_file(self, file: Path):
		"""Import a manifest file."""
		tree = ElementTree.parse(file)
		root = tree.getroot()

		if self.version is None and "version" in root.attrib:
			self.version = root.attrib["version"]
		if self.type is None and "type" in root.attrib:
			self.type = root.attrib["type"]
		if self.target_level is None and "target-level" in root.attrib:
			self.target_level = root.attrib["target-level"]

		# Parse HALs
		for entry in root:
			if entry.tag != "hal":
				continue

			hal_format = entry.get("format")
			if hal_format == "aidl":
				self.entries.append(AidlHal.from_entry(entry))
			elif hal_format == "hidl":
				self.entries.append(HidlHal.from_entry(entry))
			else:
				LOGW(f"Unknown HAL type {hal_format}")
