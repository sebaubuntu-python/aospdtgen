from aospdtgen.proprietary_files.section import Section, register_section

class PasrSection(Section):
	name = "PASR"
	interfaces = [
		"vendor.qti.memory.pasrmanager",
		"vendor.qti.power.pasrmanager",
	]
	apps = [
		"pasrservice",
	]

register_section(PasrSection)
