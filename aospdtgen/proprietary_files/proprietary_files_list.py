#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from pathlib import Path
from sebaubuntu_libs.libandroid.partitions.partition import AndroidPartition
from sebaubuntu_libs.libreorder import strcoll_files_key
from typing import Dict, List, Optional

from aospdtgen.proprietary_files.ignore import is_blob_allowed
from aospdtgen.proprietary_files.section import Section, sections


class ProprietaryFilesList:
    """Class representing a proprietary files list."""

    def __init__(self, partitions: List[AndroidPartition]):
        """Initialize a new ProprietaryFilesList object."""
        self.partitions = partitions

        self.section_to_files: Dict[Section, List[Path]] = {section: [] for section in sections}

        for partition in self.partitions:
            files: List[Path] = []

            for file in partition.files:
                file_relative = file.relative_to(partition.path)
                # Filter out ignored files
                if is_blob_allowed(file_relative):
                    files.append(file)

            for section in sections:
                matched, not_matched = section.add_files(files, partition)

                self.section_to_files[section].extend(
                    partition.model.proprietary_files_prefix / file.relative_to(partition.path)
                    for file in matched
                )

                files = not_matched

    def __str__(self) -> str:
        return self.get_formatted_list()

    def get_formatted_list(self, build_description: Optional[str] = None) -> str:
        result = ""
        if build_description:
            result += f"# Unpinned blobs from {build_description}\n"

        for section, files in self.section_to_files.items():
            if not files:
                continue

            result += f"\n# {section.name}\n"
            result += "\n".join(str(file) for file in self._sort_files(files))
            result += "\n"

        return result

    @staticmethod
    def _sort_files(files: List[Path]) -> List[Path]:
        return sorted(files, key=strcoll_files_key)
