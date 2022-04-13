from aospdtgen.proprietary_files.section import Section, register_section

class DpmSection(Section):
	name = "DPM"
	interfaces = [
		"com.qualcomm.qti.dpm.api",
		"vendor.qti.diaghal",
	]
	binaries = [
		"dpmQmiMgr",
		"dpmd",
	]
	folders = [
		"etc/dpm",
	]

register_section(DpmSection)
