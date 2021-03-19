#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.lib.liblogging import LOGI
from pathlib import Path
from xml.etree import ElementTree
from xml.etree.ElementTree import Element

"""
VINTF manifest example:

<manifest version="2.0" type="device" target-level="4">
    <hal format="hidl">
        <name>android.hardware.audio</name>
        <transport>hwbinder</transport>
        <version>6.0</version>
        <interface>
            <name>IDevicesFactory</name>
            <instance>default</instance>
        </interface>
        <fqname>@6.0::IDevicesFactory/default</fqname>
    </hal>
    <hal format="aidl">
        <name>android.hardware.light</name>
        <fqname>ILights/default</fqname>
    </hal>
    <sepolicy>
        <version>30.0</version>
    </sepolicy>
    <kernel target-level="4"/>
</manifest>
"""

class VintfInterface:
	"""
	A class representing a VINTF interfaces list
	"""
	def __init__(self, element: Element):
		self.element = element
		self.name = self.element.findtext("name")
		self.instances = [instance.text for instance in self.element.findall("instance")]

class VintfHal:
	"""
	A class representing a VINTF HAL
	"""
	def __init__(self, element: Element):
		"""
		Parse a VINTF entry
		"""
		self.element = element
		self.name = self.element.findtext("name")
		LOGI(f"Processing {self.name}")
		self.format = self.element.attrib["format"]
		if self.format == "hidl":
			self.transport = self.element.findtext("transport")
			self.version = self.element.findtext("version")
			self.interfaces = [VintfInterface(interface) for interface in self.element.findall("interface")]
		self.fqname = [interface.text for interface in self.element.findall("fqname")]

class VintfManifest:
	"""
	A class representing a VINTF manifest
	"""
	def __init__(self):
		"""
		Parse a VINTF manifest
		"""
		self.files = []
		self.version = None
		self.target_level = None
		self.entries = []

	def import_vintf(self, file: Path):
		self.files += [file]
		tree = ElementTree.parse(file)
		root = tree.getroot()

		if self.version is None and "version" in root.attrib:
			self.version = root.attrib["version"]
		if self.target_level is None and "target-level" in root.attrib:
			self.target_level = root.attrib["target-level"]

		# Parse HALs
		for entry in root:
			if entry.tag == "hal":
				self.entries.append(VintfHal(entry))
			else:
				LOGI(f"Skipped {entry.tag} entry")
