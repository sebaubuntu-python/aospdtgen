from aospdtgen.proprietary_files.section import Section, register_section

class TimeSection(Section):
	name = "Time services"
	apps = [
		"TimeService",
	]
	binaries = [
		"time_daemon",
	]
	libraries = [
		"libtime_genoff",
	]

register_section(TimeSection)
