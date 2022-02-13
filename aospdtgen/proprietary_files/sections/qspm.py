from aospdtgen.proprietary_files.section import Section, register_section

class QspmSection(Section):
	name = "QSPM"
	interfaces = [
		"vendor.qti.qspmhal",
	]
	filenames = [
		"qspm.policy",
	]

register_section(QspmSection)
