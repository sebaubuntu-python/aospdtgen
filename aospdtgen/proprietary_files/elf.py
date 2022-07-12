#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from elftools.common.exceptions import ELFError
from elftools.elf.elffile import ELFFile
from pathlib import Path
from typing import List

def get_needed_shared_libs(file: Path):
	with open(file, "rb") as f:
		try:
			elf = ELFFile(f)
			dynsec = elf.get_section_by_name(".dynamic")
			if not dynsec:
				return

			for dt_needed in dynsec.iter_tags("DT_NEEDED"):
				yield str(dt_needed.needed)
		except ELFError:
			pass

def get_shared_libs(files: List[Path]):
	for lib in files:
		if not lib.suffix == ".so":
			continue

		yield lib
