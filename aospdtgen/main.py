#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from aospdtgen import __version__ as version, current_path
from aospdtgen.utils.logging import setup_logging
from aospdtgen.devicetree import DeviceTree
from argparse import ArgumentParser
from pathlib import Path

def main():
	setup_logging()

	print(f"Android device tree generator\n"
	      f"Version {version}\n")

	parser = ArgumentParser(prog='python3 -m aospdtgen')
	parser.add_argument("dump_path", type=Path,
	                    help="path to an Android dump made with dumpyara")
	parser.add_argument("-o", "--output", type=Path, default=current_path / "output",
	                    help="custom output folder")

	args = parser.parse_args()

	dump = DeviceTree(args.dump_path)
	dump.dump_to_folder(args.output)

	print(f"\nDone! You can find the device tree in {str(args.output)}")
