from aospdtgen.proprietary_files.section import Section, register_section

class HealthSection(Section):
	name = "Health"
	interfaces = [
		"android.hardware.health",
	]

register_section(HealthSection)
