#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from pathlib import Path
from typing import List

def get_shared_libs(files: List[Path]):
	for lib in files:
		if not lib.suffix == ".so":
			continue

		yield lib
