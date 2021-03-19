from elftools.common.exceptions import ELFError
from elftools.elf.elffile import ELFFile
from pathlib import Path

def get_needed_shared_libs(file: Path) -> list[str]:
	shared_libs = []
	with open(file, "rb") as f:
		try:
			elf = ELFFile(f)
			dynsec = elf.get_section_by_name(".dynamic")
			if dynsec is not None:
				shared_libs = [str(dt_needed.needed) for dt_needed in dynsec.iter_tags("DT_NEEDED")]
		except ELFError:
			pass

	return shared_libs

def get_shared_libs(files: list[str]):
	return [lib for lib in files if lib.endswith(".so")]
