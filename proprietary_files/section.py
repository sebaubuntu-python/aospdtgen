#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from importlib import import_module
from pathlib import Path
from pkgutil import iter_modules
from re import match
from sebaubuntu_libs.libandroid.elf.elf import ELF
from sebaubuntu_libs.libandroid.partitions.partition import AndroidPartition
from sebaubuntu_libs.libexception import format_exception
from sebaubuntu_libs.liblogging import LOGE
from sebaubuntu_libs.libpath import is_relative_to
from sebaubuntu_libs.libreorder import strcoll_files_key
from sebaubuntu_libs.libstring import removesuffix
from typing import Dict, List, Type

from aospdtgen.proprietary_files.elf import get_shared_libs

class Section:
	"""Class representing a proprietary files list section."""
	name: str = "Miscellaneous"
	"""Name of the section"""
	interfaces: List[str] = []
	"""List of interfaces"""
	hardware_modules: List[str] = []
	"""List of hardware modules IDs"""
	apexes: List[str] = []
	"""List of APEXes"""
	apps: List[str] = []
	"""List of app names"""
	binaries: List[str] = []
	"""List of binaries/services"""
	libraries: List[str] = []
	"""List of libraries (omit the .so)"""
	filenames: List[str] = []
	"""List of exact file names"""
	folders: List[str] = []
	"""List of folders"""
	patterns: List[str] = []
	"""List of basic patterns (use regex)"""
	properties_prefixes: Dict[str, bool] = {}
	"""List of properties prefix to whether it's an exact match"""

	def __init__(self):
		"""Initialize the section."""
		self.files: List[Path] = []

	def add_files(self, files: List[Path], partition: AndroidPartition):
		matched: List[Path] = []
		not_matched: List[Path] = []

		for file in files:
			file_relative = file.relative_to(partition.path)
			(matched if self.file_match(file_relative) else not_matched).append(file)

		# Handle shared libs
		for file in matched:
			file_relative = file.relative_to(partition.path)
			# Check only ELFs
			if (not is_relative_to(file_relative, "bin")
					and not is_relative_to(file_relative, "lib")
					and not is_relative_to(file_relative, "lib64")):
				continue

			# Add shared libs used by the section ELFs
			needed_libs = ELF.get_needed_libs(file)
			for lib in needed_libs:
				# Skip the lib if it belongs to another section
				skip = False

				for interface in known_interfaces:
					if match(f"{interface}(@[0-9]+\\.[0-9]+|-).*\\.so", lib):
						skip = True
						break

				if removesuffix(lib, ".so") in known_libraries:
					skip = True

				if skip:
					continue

				# Recursively handle shared libs' shared libs as well
				unmatched_shared_libs = get_shared_libs(not_matched)
				for file in unmatched_shared_libs:
					if file.name != lib:
						continue

					# Move from unmatched to matched
					not_matched.remove(file)
					matched.append(file)

		self.files.extend(
			partition.model.proprietary_files_prefix / file.relative_to(partition.path)
			for file in matched
		)

		return not_matched

	def get_files(self):
		"""Returns the ordered list of files."""
		self.files.sort(key=strcoll_files_key)
		return self.files

	def file_match(self, file: Path):
		if self.name == "Miscellaneous":
			return True

		return (self._match_interfaces(file)
		        or self._match_hardware_modules(file)
		        or self._match_apexes(file)
		        or self._match_apps(file)
		        or self._match_binaries(file)
		        or self._match_init_scripts(file)
		        or self._match_libraries(file)
		        or self._match_filenames(file)
		        or self._match_folders(file)
		        or self._match_patterns(file))

	def _match_interfaces(self, file: Path):
		"""Match files against known interfaces."""
		for interface in self.interfaces:
			if is_relative_to(file, "bin") and interface in file.name:
				return True
			if is_relative_to(file, "etc/init") and interface in file.name:
				return True
			if is_relative_to(file, "etc/vintf/manifest") and interface in file.name:
				return True
			if (is_relative_to(file, "lib/hw") or is_relative_to(file, "lib64/hw")) and match(f"{interface}@[0-9]+\\.[0-9]+-impl\\.so", file.name):
				return True
			if (is_relative_to(file, "lib") or is_relative_to(file, "lib64")) and match(f"{interface}(@[0-9]+\\.[0-9]+|-).*\\.so", file.name):
				return True
		return False

	def _match_hardware_modules(self, file: Path):
		"""Match files against hardware module IDs."""
		if is_relative_to(file, "lib/hw") or is_relative_to(file, "lib64/hw"):
			for hardware_module in self.hardware_modules:
				if file.name.startswith(f"{hardware_module}.") and file.suffix == ".so":
					return True
		return False

	def _match_apexes(self, file: Path):
		"""Match APEX files."""
		return (is_relative_to(file, "apex")
		        and file.suffix == ".apex"
		        and file.stem in self.apexes)

	def _match_apps(self, file: Path):
		"""Match app APK files."""
		return ((is_relative_to(file, "app") or is_relative_to(file, "priv-app"))
		        and file.suffix == ".apk"
		        and file.stem in self.apps)

	def _match_binaries(self, file: Path):
		"""Match binary files."""
		return is_relative_to(file, "bin") and file.name in self.binaries

	def _match_init_scripts(self, file: Path):
		"""Match init scripts for known binaries."""
		if is_relative_to(file, "etc/init"):
			for binary in self.binaries:
				if match(f"(init)?(.)?{binary}\\.rc", file.name):
					return True
		return False

	def _match_libraries(self, file: Path):
		"""Match shared library files."""
		return ((is_relative_to(file, "lib/") or is_relative_to(file, "lib64/"))
		        and file.suffix == ".so"
		        and file.stem in self.libraries)

	def _match_filenames(self, file: Path):
		"""Match files by exact filename."""
		return file.name in self.filenames

	def _match_folders(self, file: Path):
		"""Match files by parent folder."""
		for folder in [str(folder) for folder in file.parents]:
			if folder in self.folders:
				return True
		return False

	def _match_patterns(self, file: Path):
		"""Match files against regex patterns."""
		return any(match(pattern, str(file)) for pattern in self.patterns)

	def property_match(self, prop: str):
		"""Check if the property matches the prefixes."""
		for prefix, exact_match in self.properties_prefixes.items():
			if prop == prefix if exact_match else prop.startswith(prefix):
				return True

		return False

sections: List[Section] = []
known_interfaces: List[str] = []
known_libraries: List[str] = []

def register_section(section: Type[Section]):
	sections.append(section())

	for interface in section.interfaces:
		assert interface not in known_interfaces, f"Duplicate interface: {interface}"
		known_interfaces.append(interface)

	for library in section.libraries:
		assert library not in known_libraries, f"Duplicate shared library: {library}"
		known_libraries.append(library)

def register_sections(sections_path: Path):
	"""Import all the sections and let them execute register_section()."""
	for section_name in [name for _, name, _ in iter_modules([str(sections_path)])]:
		try:
			import_module(f'aospdtgen.proprietary_files.sections.{section_name}')
		except Exception as e:
			LOGE(f"Error importing section {section_name}:\n"
			     f"{format_exception(e)}")
