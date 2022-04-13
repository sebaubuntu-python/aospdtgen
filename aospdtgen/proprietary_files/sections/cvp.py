from aospdtgen.proprietary_files.section import Section, register_section

class CvpSection(Section):
	name = "CVP"
	interfaces = [
		"vendor.qti.hardware.cvp",
	]

register_section(CvpSection)
