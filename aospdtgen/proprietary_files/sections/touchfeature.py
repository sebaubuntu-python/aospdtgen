from aospdtgen.proprietary_files.section import Section, register_section

class TouchfeatureSection(Section):
	name = "Touchfeature"
	interfaces = [
		"vendor.xiaomi.hardware.touchfeature",
	]

register_section(TouchfeatureSection)
