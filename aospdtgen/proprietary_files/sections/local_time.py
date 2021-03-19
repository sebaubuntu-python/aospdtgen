from aospdtgen.proprietary_files.section import Section, register_section

class LocalTimeSection(Section):
	name = "Local time"
	hardware_modules = [
		"local_time",
	]

register_section(LocalTimeSection)
