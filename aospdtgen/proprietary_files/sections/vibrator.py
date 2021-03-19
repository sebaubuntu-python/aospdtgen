from aospdtgen.proprietary_files.section import Section, register_section

class VibratorSection(Section):
	name = "Vibrator"
	interfaces = [
		"android.hardware.vibrator",
		"vendor.qti.hardware.vibrator",
	]
	hardware_modules = [
		"vibrator",
	]

class VibratorXiaomiSection(Section):
	name = "Vibrator (Xiaomi)"
	interfaces = [
		"vendor.xiaomi.hardware.vibratorfeature",
	]

register_section(VibratorSection)
register_section(VibratorXiaomiSection)
