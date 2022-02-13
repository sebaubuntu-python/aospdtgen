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
		self.files: list[str] = []

	def add_files(self, partition: AndroidPartition):
		matched: list[str] = []
		not_matched: list[str] = []

		for file in partition.files:
			if self.file_match(file):
				matched.append(file)
			else:
				not_matched.append(file)

		# Handle shared libs
		for file in matched:
			# Check only ELFs
			if (not file.startswith("bin/")
					and not file.startswith("lib/")
					and not file.startswith("lib64/")):
				continue

			# Add shared libs used by the section ELFs
			needed_libs = get_needed_shared_libs(f"{partition.dump_path}/{partition.real_path}/{file}")
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
					if Path(file).name != lib:
						continue

					# Move from unmatched to matched
					not_matched.remove(file)
					matched.append(file)

		self.files.extend([f"{partition.proprietary_files_prefix}{file}" for file in matched])
		self.files.sort(key=reorder_key)
		partition.files = not_matched
		partition.files.sort(key=reorder_key)

		return not_matched

	def file_match(self, file: str):
		if self.name == "Miscellaneous":
			return True

		# Interfaces
		for interface in self.interfaces:
			# Service binary (we try)
			if match(f"bin(/hw)?/.*{interface}.*", file):
				return True

			# Service init script (we try)
			if match(f"etc/init/.*{interface}.*\.rc", file):
				return True

			# VINTF fragment (again, we try)
			if match(f"etc/vintf/manifest/.*{interface}.*\.xml", file):
				return True

			# Passthrough impl (only HIDL)
			if match(f"lib(64)?/hw/{interface}@[0-9]+\.[0-9]+-impl\.so", file):
				return True

			# Interface libs (AIDL and HIDL)
			if match(f"lib(64)?/{interface}(@[0-9]+\.[0-9]+|-).*\.so", file):
				return True

		# Hardware modules
		if file.startswith("lib/hw/") or file.startswith("lib64/hw/"):
			for hardware_module in self.hardware_modules:
				if match(f"lib(64)?/hw/{hardware_module}\..*\.so", file):
					return True

		# Apps
		if file.startswith("app/") or file.startswith("priv-app/"):
			app_name = file.removeprefix("app/" if file.startswith("app/") else "priv-app/")
			app_name = list(Path(app_name).parts)[0]
			if app_name in self.apps:
				return True

		# Binaries
		if file.startswith("bin/"):
			binary_name = file.removeprefix("bin/hw/" if file.startswith("bin/hw/") else "bin/")
			if binary_name in self.binaries:
				return True

		# Init scripts
		if file.startswith("etc/init/"):
			init_name = Path(file).name
			for binary in self.binaries:
				if match(f"(init)?(.)?{binary}\.rc", init_name):
					return True

		# Libraries
		if file.startswith("lib/") or file.startswith("lib64/"):
			library_name = Path(file).name
			if library_name.endswith(".so") and library_name.removesuffix(".so") in self.libraries:
				return True

		# Filenames
		if Path(file).name in self.filenames:
			return True

		# Folders
		for folder in [str(folder) for folder in Path(file).parents]:
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
