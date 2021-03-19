from aospdtgen.proprietary_files.section import Section, register_section

class OemLockSection(Section):
	name = "OEM lock"
	interfaces = [
		"android.hardware.oemlock",
	]

register_section(OemLockSection)
