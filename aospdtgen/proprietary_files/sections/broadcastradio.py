from aospdtgen.proprietary_files.section import Section, register_section

class BroadcastRadioSection(Section):
	name = "Broadcast radio"
	interfaces = [
		"android.hardware.broadcastradio",
	]

register_section(BroadcastRadioSection)
