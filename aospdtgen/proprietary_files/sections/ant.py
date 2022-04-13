from aospdtgen.proprietary_files.section import Section, register_section

class AntSection(Section):
	name = "ANT"
	interfaces = [
		"com.dsi.ant",
		"vendor.xiaomi.hardware.antdtx",
	]

register_section(AntSection)
