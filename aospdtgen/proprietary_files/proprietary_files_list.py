#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from sebaubuntu_libs.libandroid.partitions.partition import AndroidPartition
from sebaubuntu_libs.libandroid.partitions.partition_model import TREBLE
from typing import List, Optional

from aospdtgen.proprietary_files.ignore import is_blob_allowed
from aospdtgen.proprietary_files.section import Section, sections

class ProprietaryFilesList:
	"""Class representing a proprietary files list."""
	def __init__(self, partitions: List[AndroidPartition]):
		"""Initialize a new ProprietaryFilesList object."""
		self.partitions = partitions

		self.sections: List[Section] = [section() for section in sections]
		misc_section = Section()

		for partition in self.partitions:
			files = []

			for file in partition.files:
				file_relative = file.relative_to(partition.path)
				# Filter out ignored files
				if is_blob_allowed(file_relative):
					files.append(file)

			for section in self.sections:
				files = section.add_files(files, partition)

			if partition.model.group != TREBLE:
				continue

			misc_section.add_files(files, partition)

		self.sections.append(misc_section)

	def __str__(self) -> str:
		return self.get_formatted_list()

	def get_formatted_list(self, build_description: Optional[str] = None) -> str:
		result = ""
		if build_description:
			result += f"# Unpinned blobs from {build_description}\n"

		for section in self.sections:
			if not section.files:
				continue

			result += (f"\n# {section.name}\n")
			result += "\n".join(str(file) for file in section.get_files())
			result += "\n"

		return result
