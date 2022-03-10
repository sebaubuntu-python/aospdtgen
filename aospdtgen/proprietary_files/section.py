from aospdtgen.lib.libexception import format_exception
from aospdtgen.lib.liblogging import LOGE
from aospdtgen.proprietary_files.elf import get_needed_shared_libs, get_shared_libs
from aospdtgen.utils.partition import AndroidPartition
from aospdtgen.utils.reorder import reorder_key
from importlib import import_module
from pathlib import Path
from pkgutil import iter_modules
from re import match

class Section:
	name: str = "Miscellaneous"
	"""Name of the section"""
	interfaces: list[str] = []
	"""List of interfaces"""
	hardware_modules: list[str] = []
	"""List of hardware modules IDs"""
	apps: list[str] = []
	"""List of app names"""
	binaries: list[str] = []
	"""List of binaries/services"""
	libraries: list[str] = []
	"""List of libraries (omit the .so)"""
	filenames: list[str] = []
	"""List of exact file names"""
	folders: list[str] = []
	"""List of folders"""
	patterns: list[str] = []
	"""List of basic patterns (use regex)"""

	def __init__(self):
		self.files: list[Path] = []

	def add_files(self, partition: AndroidPartition):
		matched: list[Path] = []
		not_matched: list[Path] = []

		for file in partition.files:
			file_relative = file.relative_to(partition.real_path)
			if self.file_match(file_relative):
				matched.append(file)
			else:
				not_matched.append(file)

		# Handle shared libs
		for file in matched:
			file_relative = file.relative_to(partition.real_path)
			# Check only ELFs
			if (not file_relative.is_relative_to("bin")
					and not file_relative.is_relative_to("lib")
					and not file_relative.is_relative_to("lib64")):
				continue

			# Add shared libs used by the section ELFs
			needed_libs = get_needed_shared_libs(file)
			for lib in needed_libs:
				# Skip the lib if it belongs to another section
				skip = False

				for interface in known_interfaces:
					if match(f"{interface}(@[0-9]+\.[0-9]+|-).*\.so", lib):
						skip = True
						break

				if lib.removesuffix(".so") in known_shared_libs:
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

		self.files.extend([partition.proprietary_files_prefix / file.relative_to(partition.real_path) for file in matched])
		self.files.sort(key=reorder_key)

		partition.files.clear()
		partition.files.extend(not_matched)
		partition.files.sort(key=reorder_key)

		return not_matched

	def file_match(self, file: Path):
		if self.name == "Miscellaneous":
			return True

		# Interfaces
		for interface in self.interfaces:
			# Service binary (we try)
			if file.is_relative_to("bin") and interface in file.name:
				return True

			# Service init script (we try)
			if file.is_relative_to("etc/init") and interface in file.name:
				return True

			# VINTF fragment (again, we try)
			if file.is_relative_to("etc/vintf/manifest") and interface in file.name:
				return True

			# Passthrough impl (only HIDL)
			if (file.is_relative_to("lib/hw") or file.is_relative_to("lib64/hw")) and match(f"{interface}@[0-9]+\.[0-9]+-impl\.so", file.name):
				return True

			# Interface libs (AIDL and HIDL)
			if (file.is_relative_to("lib") or file.is_relative_to("lib64")) and match(f"{interface}(@[0-9]+\.[0-9]+|-).*\.so", file.name):
				return True

		# Hardware modules
		if file.is_relative_to("lib/hw") or file.is_relative_to("lib64/hw"):
			for hardware_module in self.hardware_modules:
				if file.name.startswith(f"{hardware_module}.") and file.suffix == ".so":
					return True

		# Apps
		if file.is_relative_to("app") or file.is_relative_to("priv-app"):
			app_name = file.relative_to("app" if file.is_relative_to("app") else "priv-app")
			app_name = list(app_name.parts)[0]
			if app_name in self.apps:
				return True

		# Binaries
		if file.is_relative_to("bin"):
			if file.name in self.binaries:
				return True

		# Init scripts
		if file.is_relative_to("etc/init"):
			for binary in self.binaries:
				if match(f"(init)?(.)?{binary}\.rc", file.name):
					return True

		# Libraries
		if file.is_relative_to("lib/") or file.is_relative_to("lib64/"):
			if file.suffix == ".so" and file.stem in self.libraries:
				return True

		# Filenames
		if file.name in self.filenames:
			return True

		# Folders
		for folder in [str(folder) for folder in file.parents]:
			if folder in self.folders:
				return True

		# Patterns
		if [pattern for pattern in self.patterns if match(pattern, str(file))]:
			return True

		return False

sections: list[Section] = []
known_interfaces: list[str] = []
known_shared_libs: list[str] = []

def register_section(section: Section):
	sections.append(section)
	known_interfaces.extend(section.interfaces)
	known_shared_libs.extend(section.libraries)

def register_sections(sections_path: Path):
	"""Import all the sections and let them execute register_section()."""
	for section_name in [name for _, name, _ in iter_modules([str(sections_path)])]:
		try:
			import_module(f'aospdtgen.proprietary_files.sections.{section_name}')
		except Exception as e:
			LOGE(f"Error importing section {section_name}:\n"
			     f"{format_exception(e)}")
