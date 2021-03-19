from aospdtgen.proprietary_files.section import Section, register_section

class SoundtriggerSection(Section):
	name = "Soundtrigger"
	interfaces = [
		"android.hardware.soundtrigger",
	]
	hardware_modules = [
		"sound_trigger",
	]

register_section(SoundtriggerSection)
