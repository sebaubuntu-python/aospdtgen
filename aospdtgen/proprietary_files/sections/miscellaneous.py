#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from pathlib import Path
from sebaubuntu_libs.libandroid.partitions.partition import AndroidPartition
from sebaubuntu_libs.libandroid.partitions.partition_model import PartitionGroup
from typing import List, Tuple

from aospdtgen.proprietary_files.section import Section


class MiscellaneousSection(Section):
    """This section must not be registered."""

    name = "Miscellaneous"

    @classmethod
    def add_files(
        cls,
        files: List[Path],
        partition: AndroidPartition,
    ) -> Tuple[List[Path], List[Path]]:
        if partition.model.group != PartitionGroup.TREBLE:
            return ([], files)

        return (files, [])

    @classmethod
    def file_match(cls, file: Path) -> bool:
        raise NotImplementedError("MiscellaneousSection should not be used for matching files")

    @classmethod
    def property_match(cls, prop: str):
        return True
