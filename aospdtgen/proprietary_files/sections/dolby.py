from aospdtgen.proprietary_files.section import Section, register_section

class DolbySection(Section):
	name = "Dolby"
	interfaces = [
		"vendor.dolby.hardware.dms",
	]

register_section(DolbySection)
