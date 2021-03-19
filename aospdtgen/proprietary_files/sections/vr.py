from aospdtgen.proprietary_files.section import Section, register_section

class VrSection(Section):
	name = "VR"
	interfaces = [
		"android.hardware.vr",
	]
	hardware_modules = [
		"vr",
	]

register_section(VrSection)
