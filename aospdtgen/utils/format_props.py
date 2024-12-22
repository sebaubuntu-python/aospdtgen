#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from pathlib import Path
from typing import Dict
from sebaubuntu_libs.libandroid.props import BuildProp

from aospdtgen.proprietary_files.section import sections
from aospdtgen.utils.ignored_props import IGNORED_PROPS

def dump_partition_build_prop(build_prop: BuildProp, destination_file_path: Path):
	"""Filter, order and format the build properties and write to file."""
	filtered_build_props = BuildProp()
	filtered_build_props.import_props(build_prop)

	# Remove ignored properties
	for ignored_prop in IGNORED_PROPS:
		filtered_build_props.pop(ignored_prop, None)

	# Don't write the file if there are no properties
	if not filtered_build_props:
		return

	section_to_props: Dict[str, BuildProp] = {}

	for section in sections:
		section_props = BuildProp()

		# Check if the prop belongs to the section
		for key, value in filtered_build_props.items():
			if section.property_match(key):
				section_props.set_prop(key, value)

		# Remove the matched properties from the filtered build props
		for prop in section_props.keys():
			filtered_build_props.pop(prop, None)

		if section_props:
			section_to_props[section.name] = section_props
	
	# Add the non matched props to a "Miscellaneous" section
	if filtered_build_props:
		section_to_props["Miscellaneous"] = filtered_build_props

	# Write the properties to the file
	with destination_file_path.open("w") as f:
		for section, props in section_to_props.items():
			f.write(f"# {section}\n")
			for prop in sorted(props.keys()):
				f.write(f"{prop}={build_prop.get_prop(prop)}\n")
			f.write("\n")
