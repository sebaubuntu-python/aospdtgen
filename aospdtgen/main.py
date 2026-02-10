#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from argparse import ArgumentParser
from pathlib import Path
from sebaubuntu_libs.liblocale import setup_locale
from sebaubuntu_libs.liblogging import setup_logging

from aospdtgen import __version__ as version, current_path
from aospdtgen.device_tree import DeviceTree

def main():
	setup_logging()

	print(f"Android device tree generator\n"
	      f"Version {version}\n")

	parser = ArgumentParser(prog='python3 -m aospdtgen')
	parser.add_argument("dump_path", type=Path,
	                    help="path to an Android dump made with dumpyara")
	parser.add_argument("-o", "--output", type=Path, default=current_path / "output",
	                    help="custom output folder")
	parser.add_argument("-c", "--codename", type=str, default=None,
	                    help="override the device codename (e.g., re5c33)")

	extract_group = parser.add_mutually_exclusive_group()
	extract_group.add_argument("--python", action="store_true", default=True,
	                           help="generate Python-based extract scripts (LineageOS >= 23.0, default)")
	extract_group.add_argument("--shell", action="store_true",
	                           help="generate shell-based extract scripts (LineageOS <= 22.x)")

	args = parser.parse_args()

	# If --shell is specified, python should be False
	extract_mode = "shell" if args.shell else "python"

	setup_locale()

	dump = DeviceTree(args.dump_path, codename_override=args.codename)
	dump.dump_to_folder(args.output, extract_mode=extract_mode)
	dump.cleanup()

	print(f"\nDone! You can find the device tree in {str(args.output)}")
