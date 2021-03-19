from aospdtgen.proprietary_files.section import Section, register_section

class KeymasterSection(Section):
	name = "Keymaster"
	interfaces = [
		"android.hardware.keymaster",
	]
	hardware_modules = [
		"keystore",
	]

register_section(KeymasterSection)
