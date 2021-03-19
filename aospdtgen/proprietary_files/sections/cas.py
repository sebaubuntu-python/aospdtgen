from aospdtgen.proprietary_files.section import Section, register_section

class CasSection(Section):
	name = "CAS"
	interfaces = [
		"android.hardware.cas",
	]

register_section(CasSection)
