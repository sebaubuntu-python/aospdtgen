from aospdtgen.proprietary_files.section import Section, sections
from aospdtgen.utils.partition import TREBLE, AndroidPartition

class ProprietaryFilesList:
	def __init__(self, partitions: list[AndroidPartition], build_description: str = None):
		self.partitions = partitions
		self.build_description = build_description

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
		result = ""
		if self.build_description:
			result += f"# Unpinned blobs from {self.build_description}\n"

		for section in self.sections:
			if not section.files:
				continue

			result += (f"\n# {section.name}\n")
			result += "\n".join([str(file) for file in section.files])
			result += "\n"

		return result
