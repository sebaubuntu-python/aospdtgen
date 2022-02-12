from aospdtgen.proprietary_files.section import Section, register_section

class AlarmSection(Section):
	name = "Alarm"
	interfaces = [
		"vendor.qti.hardware.alarm",
	]
	apps = [
		"PowerOffAlarm",
	]

register_section(AlarmSection)
