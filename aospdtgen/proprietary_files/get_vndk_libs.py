#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from base64 import b64decode
from typing import List, Set
from requests import get

from aospdtgen.proprietary_files.ignore import IGNORE_SHARED_LIBS

ARCHS = [
	"arm",
	"arm64",
	"x86",
	"x86_64",
]

FIRST_VNDK_VERSION = 29

# VNDK version, architecture, file name
FROZEN_VNDK_LIST_URL = "https://android.googlesource.com/platform/prebuilts/vndk/v{}/+/main/{}/configs/{}?format=TEXT"

# VNDK version
GSI_VNDK_LIST_URL = "https://android.googlesource.com/platform/build/+/main/target/product/gsi/{}.txt?format=TEXT"

def get_vndk_file_names(vndk_version: int) -> List[str]:
	return [
		"llndk.libraries.txt",
		f"vndkcore.libraries.{vndk_version}.txt",
		f"vndkprivate.libraries.{vndk_version}.txt",
		"vndkproduct.libraries.txt",
		"vndksp.libraries.txt",
	]

def main():
	libs: Set[str] = set()

	# Add the currently known shared libraries
	libs.update(IGNORE_SHARED_LIBS)

	current_vndk_version = FIRST_VNDK_VERSION
	while True:
		print(f"Fetching VNDK libraries for version {current_vndk_version}")

		found_something = False

		# Get the GSI VNDK list
		response = get(GSI_VNDK_LIST_URL.format(current_vndk_version))
		if response.ok:
			found_something = True

			# We only need the library name
			for line in b64decode(response.content).decode("ascii").splitlines():
				lib = line.split()[-1]
				libs.add(lib)

		# Now get the VNDK list for each architecture
		for arch in ARCHS:
			for file in get_vndk_file_names(current_vndk_version):
				response = get(FROZEN_VNDK_LIST_URL.format(current_vndk_version, arch, file))
				if response.ok:
					found_something = True

					for line in b64decode(response.content).decode("ascii").splitlines():
						libs.add(line)

		if not found_something:
			if current_vndk_version == FIRST_VNDK_VERSION:
				raise Exception(
					"Failed to fetch the GSI VNDK list for"
					f" version {current_vndk_version}, Google dropped it?"
				)

			print(f"Failed to fetch the VNDK list for version {current_vndk_version}, stopping")

			break

		current_vndk_version += 1

	# Print the list of libraries
	print(
		"\n".join(
			f'"{lib}",'
			for lib in sorted(libs)
		)
	)

main()
