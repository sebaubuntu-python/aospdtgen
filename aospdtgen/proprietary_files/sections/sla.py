from aospdtgen.proprietary_files.section import Section, register_section

class SlaSection(Section):
	name = "SLA"
	interfaces = [
		"vendor.qti.sla.service",
	]

register_section(SlaSection)
