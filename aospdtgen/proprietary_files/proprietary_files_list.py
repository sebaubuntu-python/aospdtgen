#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen.proprietary_files.ignore import is_blob_allowed
from aospdtgen.proprietary_files.section import Section, sections
from aospdtgen.utils.partition import TREBLE, AndroidPartition

class ProprietaryFilesList:
	"""Class representing a proprietary files list."""
	def __init__(self, partitions: list[AndroidPartition]):
		"""Initialize a new ProprietaryFilesList object."""
		self.partitions = partitions

		# Filer out ignored files before starting
		for partition in self.partitions:
			allowed, not_allowed = [], []

			for file in partition.files:
				file_relative = file.relative_to(partition.real_path)
				(allowed if is_blob_allowed(file_relative) else not_allowed).append(file)

			partition.files = allowed

		self.sections: list[Section] = [section() for section in sections]
		for section in self.sections:
			for partition in self.partitions:
				section.add_files(partition)

		misc_section = Section()

		for partition in self.partitions:
			if partition.model.group != TREBLE:
				continue

			misc_section.add_files(partition)

		self.sections.append(misc_section)

	def __str__(self) -> str:
		return self.get_formatted_list()

	def get_formatted_list(self, build_description: str = None) -> str:
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
